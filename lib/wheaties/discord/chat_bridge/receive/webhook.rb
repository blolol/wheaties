module Wheaties
  module Discord
    module ChatBridge
      module Receive
        class Webhook
          CACHE = {}

          def initialize(channel_id)
            @channel_id = channel_id
          end

          def execute(payload)
            response = HTTP.post(url, json: payload)
            logger.debug("Executed Discord webhook: id=#{id} payload=#{payload.inspect} " \
              "response=#{response.status.to_i}")
          end

          private

          def api_token
            ENV['DISCORD_BOT_TOKEN']
          end

          def app
            @app ||= JSON.parse(Discordrb::API::User.profile(auth_header))
          end

          def attributes
            @attributes ||= cached_webhook || find_or_create_webhook
          end

          def auth_header
            @auth_header ||= "Bot #{api_token}"
          end

          def avatar_image_data
            file_name = ENV['DISCORD_DEFAULT_AVATAR'] || 'wheaties.png'
            avatar_path = Wheaties.root.join('share/avatars', file_name)
            base64_encoded_image_data = Base64.encode64(avatar_path.read)
            "data:image/png;base64,#{base64_encoded_image_data}"
          end

          def cached_webhook
            CACHE[@channel_id]
          end

          def channel_webhooks
            JSON.parse(Discordrb::API::Channel.webhooks(auth_header, @channel_id))
          end

          def create_webhook
            audit_log_reason = "Webhook for #{webhook_name} chat bridge"
            webhook = JSON.parse(Discordrb::API::Channel.create_webhook(auth_header, @channel_id,
              webhook_name, avatar_image_data, audit_log_reason))
            logger.info("Created new webhook for channel.id=#{@channel_id} webhook.id=#{webhook['id']}")
            webhook
          end

          def find_or_create_webhook
            (find_webhook || create_webhook).tap do |webhook|
              CACHE[@channel_id] = webhook
              logger.debug("Cached webhook for channel.id=#{@channel_id} webhook.id=#{webhook['id']}")
            end
          end

          def find_webhook
            channel_webhooks.find do |webhook|
              webhook['application_id'] == app['id'] && webhook['name'] == webhook_name
            end
          end

          def id
            attributes['id']
          end

          def logger
            Wheaties.logger
          end

          def url
            attributes['url']
          end

          def webhook_name
            app['global_name'] || app['username']
          end
        end
      end
    end
  end
end
