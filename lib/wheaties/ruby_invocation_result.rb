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
      if value.is_a?(String)
        message.reply(value)
      elsif value.is_a?(Array)
        value.each { |element| reply_to_chat_based_on_type(message, element) }
      elsif value.is_a?(Numeric)
        reply_to_chat_based_on_type(message, value.to_s)
      else
        log_invalid_return_value(message, value)
      end
    end
  end
end
