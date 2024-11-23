module Wheaties
  module Relay
    class ChatEvent
      def initialize(payload)
        @payload = payload
      end

      def forward
        if valid?
          representations.each(&:forward)
        else
          schema_name = schema_path.basename
          logger.warn("Chat relay message doesn't conform to #{schema_name}: #{payload.inspect}")
        end
      end

      private

      attr_reader :payload

      def logger
        Wheaties.logger
      end

      def representations
        [irc_representation, discord_representation].compact
      end

      def valid?
        JSON::Validator.validate(schema_path.to_s, payload)
      end
    end
  end
end
