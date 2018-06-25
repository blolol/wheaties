module Wheaties
  class Logger
    def debug(name, &block)
      log(:debug, name, &block)
    end

    def debug?
      true
    end

    def error(name, &block)
      log(:error, name, &block)
    end

    def error?
      true
    end

    def fatal(name, &block)
      log(:fatal, name, &block)
    end

    def fatal?
      true
    end

    def info(name, &block)
      log(:info, name, &block)
    end

    def info?
      true
    end

    def level=(level)
      logger.level = level
    end

    def log(level, name, &block)
      messages = if block_given?
        Array(block.call).map { |message| "#{name} #{message}" }
      else
        Array(name)
      end

      logger.log(messages, level.to_sym)
    end

    def warn(name, &block)
      log(:warn, name, &block)
    end

    def warn?
      true
    end

    private

    def logger
      @logger ||= Wheaties.bot.loggers
    end
  end
end
