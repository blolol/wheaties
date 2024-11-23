module Wheaties
  module Relay
    class ChatEventV2 < ChatEvent
      private

      def discord_representation
        return unless discord_webhook_payload = payload.dig('representations', 'discord')
        DiscordRepresentation.new(to: to, webhook_payload: discord_webhook_payload)
      end

      def irc_representation
        return unless irc = payload.dig('representations', 'irc')
        IrcRepresentation.new(event: irc['type'], to: to, from: irc['from'], text: irc['text'])
      end

      def schema_path
        Wheaties.root.join('lib/wheaties/schemas/chat_event_v2.json')
      end

      def to
        payload['to']
      end
    end
  end
end
