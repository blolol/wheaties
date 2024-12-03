module Wheaties
  module ChatBridge
    class ChatEventServer
      def initialize(server_payload)
        @payload = server_payload
      end

      def [](key)
        payload[key]
      end

      def id
        payload['id']
      end

      def name
        payload['name']
      end

      def platform
        @platform ||= ActiveSupport::StringInquirer.new(payload['platform'])
      end

      private

      attr_reader :payload
    end
  end
end
