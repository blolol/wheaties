module Wheaties
  module Discord
    module ChatBridge
      module Transmit
        class WebhookCache
          def initialize(bot)
            @bot_id = bot.profile.id.to_s
            @cache ||= Hash.new do |hash, webhook_id|
              webhook_id = webhook_id.to_s
              hash[webhook_id] = lookup(webhook_id)
            end
          end

          def ours?(webhook_id)
            @cache[webhook_id.to_s]
          end

          private

          def all_server_webhooks
            response = Discordrb::API::Server.webhooks(Wheaties.platform.authorization_header,
              Wheaties.platform.server_id)
            JSON.parse(response)
          end

          def lookup(webhook_id)
            webhook_id.to_s.in?(our_webhook_ids)
          end

          def our_webhook_ids
            all_server_webhooks.select do |webhook|
              webhook['application_id'].to_s == @bot_id
            end.map do |webhook|
              webhook['id'].to_s
            end
          end
        end
      end
    end
  end
end
