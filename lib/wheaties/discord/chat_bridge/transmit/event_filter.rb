module Wheaties
  module Discord
    module ChatBridge
      module Transmit
        class EventFilter
          def initialize(event)
            @event = event
            @@webhook_cache ||= WebhookCache.new(event.bot)
          end

          def ignore?
            case event
            when Discordrb::Events::MessageEvent
              ignore_message_event?
            else
              false
            end
          end

          private

          attr_reader :event

          def from_our_webhook?
            event.message.webhook? && @@webhook_cache.ours?(event.message.webhook_id)
          end

          def ignore_message_event?
            event.message.from_bot? || from_our_webhook?
          end
        end
      end
    end
  end
end
