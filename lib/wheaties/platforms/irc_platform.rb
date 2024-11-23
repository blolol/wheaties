module Wheaties
  class IrcPlatform
    # The app type to use when configuring Bugsnag.
    #
    # @return [String] the string `"irc"`
    def bugsnag_app_type
      'irc'
    end

    # The logger to use.
    #
    # @return [Wheaties::Logger] an instance of Wheaties' Cinch logger facade
    # @see Wheaties::Logger
    # @see Wheaties.configure_logger
    def logger
      Wheaties::Logger.new
    end

    # Starts the bot by calling {Cinch::Bot#start}.
    def start
      Wheaties.bot.start
    end
  end
end
