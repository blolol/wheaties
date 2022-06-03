module Wheaties
  class RelayEvent
    include Cinch::Helpers

    def initialize(bot, payload)
      @bot = bot
      @payload = payload
    end

    def deliver
      if valid?
        to.safe_send(message)
      else
        Wheaties.logger.warn("Invalid relay event: #{payload.inspect}")
      end
    end

    private

    attr_reader :bot, :payload

    def event
      @event ||= JSON.parse(payload)['event']
    end

    def message
      event['text']
    end

    def to
      Target(event['to'])
    end

    def valid?
      event.present? && %w(from text to).all? { |key| event.key?(key) }
    rescue JSON::ParserError
      false
    end
  end
end
