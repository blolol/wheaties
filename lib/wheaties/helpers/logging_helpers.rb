module Wheaties
  module LoggingHelpers
    private

    def caller_line_number
      caller_locations(2, 1)&.first&.lineno || 1
    end

    def debug(*args)
      prefix = "[#{stack.last.name}##{stack.last.id}:#{caller_line_number}]"
      debug_message = "#{prefix} #{formatted_args(args)}"

      message.user.send(debug_message)
      logger.debug(debug_message)
    end

    def formatted_args(args)
      if args.size == 1 && args.first.is_a?(Hash)
        args.first.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
      else
        args.map(&:to_s).join(' ')
      end
    end

    def logger
      bot.loggers
    end
  end
end
