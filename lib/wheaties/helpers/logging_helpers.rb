module Wheaties
  module LoggingHelpers
    private

    def debug(*args)
      inspected_args = args.map(&:inspect).join(' ')
      debug_message = "[#{stack.last.name}] #{inspected_args}"
      @message.user.send(debug_message)
      logger.debug(debug_message)
    end

    def logger
      bot.loggers
    end
  end
end
