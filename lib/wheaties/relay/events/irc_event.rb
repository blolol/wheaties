module Wheaties
  module Relay
    class IrcEvent < BaseEvent
      include Cinch::Helpers

      def initialize(payload)
        @payload = payload
      end

      def deliver
        unless valid?
          Wheaties.logger.warn("Invalid IRC chat relay event: #{payload.inspect}")
          return
        end

        case type
        when 'action'
          deliver_action
        when 'message'
          deliver_message
        when 'notice'
          deliver_notice
        else
          Wheaties.logger.warn("Invalid IRC chat relay event type #{type.inspect}: " \
            "#{payload.inspect}")
        end
      end

      private

      attr_reader :payload

      def bot
        Wheaties.bot
      end

      def deliver_action
        if relaymsg?
          to.safe_action(message, as: from)
        else
          to.safe_action(message)
        end
      end

      def deliver_message
        if relaymsg?
          to.safe_send(message, as: from)
        else
          to.safe_send(message)
        end
      end

      def deliver_notice
        to.safe_notice(message)
      end

      def event
        payload['event']
      end

      def from
        event['from'] || bot.nick
      end

      def message
        event['text']
      end

      def relaymsg?
        from.include?('/')
      end

      def schema_path
        Wheaties.root.join('lib/wheaties/schemas/irc_event_v1.json')
      end

      def to
        Target(event['to'])
      end

      def type
        event['type'] || 'message'
      end

      def valid?
        JSON::Validator.validate(schema_path.to_s, payload)
      end
    end
  end
end
