module Wheaties
  module Irc
    module ChatBridge
      module Transmit
        class StreamEntry
          include Wheaties::ChatBridge::StreamKeyable

          STREAM_LIMIT = Integer(ENV['CHAT_BRIDGE_STREAM_LIMIT'] || 1000)

          def initialize(type:, event:, content:)
            @type = type
            @event = event
            @content = content
            @timestamp = Time.now(in: 'UTC')
          end

          def publish
            redis.xadd(stream_key, fields, maxlen: STREAM_LIMIT, approximate: true).tap do |id|
              log_published_entry(id)
            end
          end

          private

          attr_reader :content, :event, :timestamp, :type

          def channel_name
            event.channel? ? event.channel.name : event.user.nick
          end

          def channel_type
            event.channel? ? 'channel' : 'dm'
          end

          def fields
            @fields ||= {
              type: payload[:type],
              timestamp: payload[:timestamp],
              :'server.name' => payload.dig(:server, :name),
              :'channel.name' => payload.dig(:channel, :name),
              payload: JSON.dump(payload)
            }
          end

          def log_published_entry(id)
            formatted_fields = fields.map { |k, v| "#{k}=#{v}" }.join(' ')
            logger.debug("Published event: stream=#{stream_key} id=#{id} #{formatted_fields}")
          end

          def logger
            Wheaties.logger
          end

          def payload
            @payload ||= {
              version: 1,
              type: type,
              timestamp: timestamp.iso8601,
              server: {
                platform: 'irc',
                name: ENV['IRC_SERVER']
              },
              channel: {
                name: channel_name,
                type: channel_type
              },
              user: {
                name: event.user.nick,
                host: event.user.host,
                user: event.user.user,
                realname: event.user.realname,
                authname: event.user.authname
              },
              content: content
            }
          end

          def redis
            Wheaties.redis
          end
        end
      end
    end
  end
end
