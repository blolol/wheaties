module Wheaties
  module Irc
    module ChatBridge
      module Receive
        class CinchPlugin
          include Cinch::Plugin
          include Wheaties::ChatBridge::StreamKeyable

          INITIAL_ENTRY_ID = '$'.freeze
          STREAM_BLOCKING_READ_MS = 30.seconds.in_milliseconds

          listen_to :connect, method: :on_connect

          private

          def log_event(id, fields)
            formatted_fields = fields.map { |k, v| "#{k}=#{v}" }.join(' ')
            logger.debug("Received event: stream=#{stream_key} id=#{id} #{formatted_fields}")
          end

          def logger
            Wheaties.logger
          end

          def on_connect(event)
            logger.info("Listening for chat bridge events on #{stream_key}")
            stream_chat_events
          end

          def redis
            Wheaties.redis
          end

          def stream_chat_events
            @last_entry_id = INITIAL_ENTRY_ID

            loop do
              entries = redis.xread(stream_key, @last_entry_id, block: STREAM_BLOCKING_READ_MS)
              next unless entries.key?(stream_key)

              entries[stream_key].each do |id, fields|
                log_event(id, fields)
                ChatEvent.from_stream_entry(id, fields).deliver
                @last_entry_id = id
              end
            end
          end
        end
      end
    end
  end
end
