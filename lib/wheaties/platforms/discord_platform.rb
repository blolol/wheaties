module Wheaties
  class DiscordPlatform
    # The app type to use when configuring Bugsnag.
    #
    # @return [String] the string `"discord"`
    def bugsnag_app_type
      'discord'
    end

    # The logger to use.
    #
    # @return [Wheaties::DiscordLoggerFacade] a facade for {Discordrb::Logger}
    # @see Wheaties::DiscordLoggerFacade
    # @see Wheaties::Logger
    # @see Wheaties.configure_logger
    def logger
      DiscordLoggerFacade.new(Discordrb::LOGGER)
    end

    # Starts the Discord bot by calling {Discordrb::Bot#run}.
    def start
      Wheaties.bot.run
    end
  end
end
