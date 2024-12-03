module Wheaties
  module ChatBridge
    class StreamKey
      SUFFIX = ':chat:events'.freeze

      def initialize(environment)
        @environment = environment
      end

      def to_s
        prefix << SUFFIX
      end

      private

      def prefix
        case @environment
        when 'development' then 'dev'
        when 'staging' then 'stg'
        when 'production' then 'prd'
        when 'test' then 'tst'
        else
          raise "Unknown Wheaties environment name: #{@environment.inspect}"
        end
      end
    end
  end
end
