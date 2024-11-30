module Wheaties
  module ChatBridge
    module StreamKeyable
      private

      def stream_key
        @@stream_key ||= "#{stream_key_prefix}:chat:events"
      end

      def stream_key_prefix
        @@stream_key_prefix ||= case Wheaties.env
          when 'development' then 'dev'
          when 'staging' then 'stg'
          when 'production' then 'prd'
          else
            raise "Unknown Wheaties environment name: #{Wheaties.env.inspect}"
          end
      end
    end
  end
end
