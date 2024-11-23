module Wheaties
  class RelayPlugin
    include Cinch::Plugin

    listen_to :connect, method: :on_connect

    private

    def channel
      Relay::ChatRelay::RELAY_TO_IRC_REDIS_PUBSUB_CHANNEL
    end

    def deliver_message(json)
      payload = JSON.parse(json)
      Relay::IrcEvent.new(payload).deliver
    rescue JSON::ParserError
      logger.warn("[#{self.class.name}] Malformed event JSON: #{json}")
    end

    def logger
      Wheaties.logger
    end

    def on_connect(connect_event)
      subscribe_to_redis_channel
      unsubscribe_from_redis_channel_on_exit
      wait_for_messages
    end

    def redis
      Wheaties.redis
    end

    def subscribe_to_redis_channel
      redis.subscribe(channel) do |on|
        on.message do |channel, json|
          deliver_message(json)
        end
      end
    end

    def unsubscribe_from_redis_channel_on_exit
      at_exit { redis.unsubscribe(channel) }
    end

    def wait_for_messages
      loop { sleep 1 }
    end
  end
end
