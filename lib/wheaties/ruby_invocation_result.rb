module Wheaties
  class RubyInvocationResult
    def initialize(return_value)
      @return_value = return_value
    end

    def reply_to_chat(message)
      reply_to_chat_based_on_type(message, @return_value)
    end

    def ruby_value
      @return_value
    end

    private

    def log_invalid_return_value(message, value)
      logger = message.bot.loggers
      logger.debug("Won't reply to chat with class=#{value.class.name} value=#{value.inspect}")
    end

    def reply_to_chat_based_on_type(message, value)
      case value
      when Array
        value.each { |element| reply_to_chat_based_on_type(message, element) }
      when Numeric
        reply_to_chat_based_on_type(message, value.to_s)
      when ResponseCollector
        value.respond!(message, :irc, :plain, :ruby)
      when String
        message.reply(value)
      else
        log_invalid_return_value(message, value)
      end
    end
  end
end
