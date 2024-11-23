module Wheaties
  module Relay
    # A representation of an IRC message that has been parsed from an incoming chat relay message
    # and should be forwarded to the IRC bot process via a Redis pubsub channel.
    class IrcRepresentation
      # Instantiate a new {IrcRepresentation}.
      #
      # @param event [String] the IRC event type (`"action"`, `"message"` or `"notice"`)
      # @param to [String] the IRC channel or user to which the event should be sent
      # @param from [String, nil] set to override the bot's nick using `RELAYMSG`
      # @param text [String] the message to send
      def initialize(event:, to:, from:, text:)
        @event = event
        @to = to
        @from = from
        @text = text
      end

      def forward
        logger.debug("Publishing IRC event to Redis channel #{channel.inspect}: #{message}")
        redis.publish(channel, message)
      end

      private

      def channel
        ChatRelay::RELAY_TO_IRC_REDIS_PUBSUB_CHANNEL
      end

      def logger
        Wheaties.logger
      end

      def message
        @message ||= JSON.dump(payload)
      end

      def payload
        {
          version: 1,
          event: {
            type: @event,
            to: @to,
            from: @from,
            text: @text
          }
        }
      end

      def redis
        Wheaties.redis
      end
    end
  end
end
