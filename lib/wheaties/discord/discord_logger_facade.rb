module Wheaties
  # Acts as a facade to integrate {Wheaties::Logger} with {Discordrb::Logger}.
  #
  # @see Wheaties::Logger
  # @see Discordrb::Logger
  class DiscordLoggerFacade
    # Maps {::Logger} levels to an equivalent named set of modes accepted by
    # {Discordrb::Logger#mode=}.
    #
    # @see #level=
    LEVELS_TO_MODE_SETS = {
      ::Logger::DEBUG => :debug,
      debug: :debug,
      ::Logger::ERROR => :quiet,
      error: :quiet,
      ::Logger::FATAL => :quiet,
      fatal: :quiet,
      ::Logger::INFO => :normal,
      info: :normal,
      ::Logger::UNKNOWN => :quiet,
      unknown: :quiet,
      ::Logger::WARN => :quiet,
      warn: :quiet
    }

    # Maps {::Logger} levels to their equivalents from {Discordrb::Logger::MODES}.
    #
    # @see #log
    LEVELS_TO_MODES = {
      ::Logger::DEBUG => :debug,
      debug: :debug,
      ::Logger::ERROR => :error,
      error: :error,
      ::Logger::FATAL => :error,
      fatal: :error,
      ::Logger::INFO => :info,
      info: :info,
      ::Logger::UNKNOWN => :error,
      unknown: :error,
      ::Logger::WARN => :warn,
      warn: :warn
    }

    # Initialize a new {DiscordLoggerFacade}.
    #
    # @param logger [Discordrb::Logger] the {Discordrb::Logger} to which this facade should delegate
    def initialize(logger)
      @logger = logger
    end

    # Sets the underlying {Discordrb::Logger}'s mode using an equivalent from
    # {LEVELS_TO_MODE_SETS}.
    #
    # @param level a valid argument to {::Logger.level=}
    def level=(level)
      @logger.mode = LEVELS_TO_MODE_SETS[level]
    end

    def log(messages, level)
      mode = LEVELS_TO_MODES[level]

      messages.each do |message|
        @logger.public_send(mode, message)
      end
    end
  end
end
