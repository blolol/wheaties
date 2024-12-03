module Wheaties
  module ChatBridge
    class Stream
      INITIAL_ENTRY_ID = '$'.freeze
      STREAM_BLOCKING_READ_MS = 30.seconds.in_milliseconds

      def self.key
        @key ||= StreamKey.new(Wheaties.env).to_s
      end

      def each_entry(&block)
        logger.info("Listening for chat bridge events on #{key}")
        @last_entry_id = INITIAL_ENTRY_ID

        loop do
          entries = redis.xread(key, @last_entry_id, block: STREAM_BLOCKING_READ_MS)
          next unless entries.key?(key)

          entries[key].each do |id, fields|
            log_event(id, fields)
            block.call(id, fields)
            @last_entry_id = id
          end
        end
      end

      def key
        self.class.key
      end

      def log_event(id, fields)
        formatted_fields = fields.map { |k, v| "#{k}=#{v}" }.join(' ')
        logger.debug("Received event: stream=#{key} id=#{id} #{formatted_fields}")
      end

      def logger
        Wheaties.logger
      end

      def redis
        Wheaties.redis
      end
    end
  end
end
