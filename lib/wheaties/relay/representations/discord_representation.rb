module Wheaties
  module Relay
    # A representation of a Discord message that has been parsed from an incoming chat relay message
    # and should be forwarded to a Discord webhook URL.
    class DiscordRepresentation
      CHANNEL_CACHE = {}
      CHANNEL_MAPPINGS = JSON.parse(ENV.fetch('DISCORD_CHANNEL_MAPPINGS', '{}')).freeze
      WEBHOOK_CACHE = {}
      WEBHOOK_NAME = 'Wheaties'.freeze

      # Instantiate a new {DiscordRepresentation}.
      #
      # @param to [String] the Discord channel to which the message should be sent
      # @param webhook_payload [Hash] a Hash representing valid Discord webhook JSON
      def initialize(to:, webhook_payload:)
        @to = to
        @payload = webhook_payload
      end

      def forward
        response = HTTP.post(webhook['url'], json: payload)
        logger.info("Relayed message to Discord: channel_name=#{channel['name'].inspect} " \
          "channel_id=#{channel['id']} webhook_id=#{webhook['id']} payload=#{payload.inspect} " \
          "response=#{response.status.to_i}")
      rescue NoSuchChannelError
        logger.warn("Couldn't find a Discord channel named #{to.inspect}: #{payload.inspect}")
      end

      private

      attr_reader :payload

      def app_id
        @app_id ||= JSON.parse(Discordrb::API::User.profile(authorization_header))['id']
      end

      def authorization_header
        @authorization_header ||= "Bot #{token}"
      end

      def avatar_image_data
        file_name = ENV['DISCORD_DEFAULT_AVATAR'] || 'wheaties.png'
        avatar_path = Wheaties.root.join('share/avatars', file_name)
        base64_encoded_image_data = Base64.encode64(avatar_path.read)
        "data:image/png;base64,#{base64_encoded_image_data}"
      end

      def channel
        @channel ||= CHANNEL_CACHE[to] || channels.find do |channel|
          channel['type'] == 0 && channel['name'] == to
        end.tap do |channel|
          break unless channel
          CHANNEL_CACHE[to] = channel
          logger.debug("Cached Discord channel #{channel['name'].inspect}")
        end or raise NoSuchChannelError
      end

      def channels
        JSON.parse(Discordrb::API::Server.channels(authorization_header, server_id))
      end

      def create_webhook
        audit_log_reason = 'Webhook for Wheaties chat relay'
        JSON.parse(Discordrb::API::Channel.create_webhook(authorization_header, channel['id'],
            WEBHOOK_NAME, avatar_image_data, audit_log_reason)).tap do |webhook|
          logger.info("Created new webhook for #{channel['name']}: #{webhook['id']}")
        end
      end

      def find_webhook
        webhooks.find do |webhook|
          webhook['application_id'] == app_id && webhook['name'] == WEBHOOK_NAME
        end
      end

      def logger
        Wheaties.logger
      end

      def server_id
        ENV['DISCORD_SERVER_ID']
      end

      def to
        (CHANNEL_MAPPINGS[@to] || @to).delete_prefix('#')
      end

      def token
        ENV['DISCORD_BOT_TOKEN']
      end

      def webhook
        @webhook ||= WEBHOOK_CACHE[to] || (find_webhook || create_webhook).tap do |webhook|
          WEBHOOK_CACHE[to] = webhook
          logger.debug("Cached webhook for #{to.inspect} => #{webhook['id']}")
        end
      end

      def webhooks
        JSON.parse(Discordrb::API::Channel.webhooks(authorization_header, channel['id']))
      end

      class NoSuchChannelError < ::StandardError; end
    end
  end
end
