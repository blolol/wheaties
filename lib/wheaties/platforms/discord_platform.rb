module Wheaties
  class DiscordPlatform
    AUTHORIZATION_HEADER = "Bot #{ENV['DISCORD_BOT_TOKEN']}".freeze
    SERVER_ID = ENV['DISCORD_SERVER_ID'].freeze

    # Returns a valid `Authorization` HTTP request header to use with {Discordrb::API} request
    # methods, using the value of the `DISCORD_BOT_TOKEN` environment variable.
    #
    # @return [String] a Discord bot `Authorization` header value
    def authorization_header
      AUTHORIZATION_HEADER
    end

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

    # Returns the value of the `DISCORD_SERVER_ID` environment variable.
    #
    # @return [String] this bot's Discord server ID
    def server_id
      SERVER_ID
    end

    # Starts the Discord bot in a background thread by calling {Discordrb::Bot#run}, then starts the
    # chat bridge receiver in the current thread.
    def start
      Wheaties.bot.run(true)
      Wheaties::Discord::ChatBridge::Receive::Receiver.new.start
    end
  end
end
