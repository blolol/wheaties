module Wheaties
  module LoggingHelpers
    private

    def caller_line_number
      caller_locations(2, 1)&.first&.lineno || 1
    end

    def debug(*args)
      prefix = "[#{stack.last.name}##{stack.last.id}:#{caller_line_number}]"
      debug_message = "#{prefix} #{args.map(&:to_s).join(' ')}"

      message.user.send(debug_message)
      logger.debug(debug_message)
    end

    def logger
      bot.loggers
    end
  end
end
