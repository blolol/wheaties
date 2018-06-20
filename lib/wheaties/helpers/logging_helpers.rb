module Wheaties
  module LoggingHelpers
    private

    def debug(message)
      debug_message = "[#{stack.last.name}] #{debug_message}"
      @message.user.send(debug_message)
      logger.debug(debug_message)
    end

    def logger
      bot.loggers
    end
  end
end
