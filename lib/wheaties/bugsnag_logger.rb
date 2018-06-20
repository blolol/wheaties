module Wheaties
  class BugsnagLogger
    def initialize(bot)
      @logger = bot.loggers
    end

    def debug(name, &block)
      log(:debug, name, &block)
    end

    def info(name, &block)
      log(:info, name, &block)
    end

    def log(level, name, &block)
      messages = Array(block.call).map { |message| "#{name} #{message}" }
      @logger.log(messages, level.to_sym)
    end

    def warn(name, &block)
      log(:warn, name, &block)
    end
  end
end
