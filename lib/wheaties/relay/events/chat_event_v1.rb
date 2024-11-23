module Wheaties
  module Relay
    class ChatEventV1 < ChatEvent
      private

      def discord_formatted_text
        if irc_event == 'action'
          "_#{text}_"
        else
          text
        end
      end

      def discord_representation
        DiscordRepresentation.new(to: to, webhook_payload: discord_webhook_payload)
      end

      def discord_webhook_payload
        webhook_payload = { content: discord_formatted_text }
        webhook_payload['username'] = from if from.present?
        webhook_payload
      end

      def event
        payload['event']
      end

      def from
        event['from']
      end

      def irc_event
        event['type']
      end

      def irc_representation
        IrcRepresentation.new(event: irc_event, to: to, from: from, text: text)
      end

      def schema_path
        Wheaties.root.join('lib/wheaties/schemas/chat_event_v1.json')
      end

      def text
        event['text']
      end

      def to
        event['to']
      end
    end
  end
end
