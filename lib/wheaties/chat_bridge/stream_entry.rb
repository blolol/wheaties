module Wheaties
  module ChatBridge
    class StreamEntry
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
          server: server_payload,
          channel: channel_payload,
          user: user_payload,
          content: content
        }
      end

      def redis
        Wheaties.redis
      end

      def stream_key
        Stream.key
      end
    end
  end
end
