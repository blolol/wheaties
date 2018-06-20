module Wheaties
  class CinchPlugin
    include Cinch::Plugin

    # Constants
    COMMAND_PREFIX = ENV.fetch('COMMAND_PREFIX', '.')
    COMMAND_PATTERN = /\A#{Regexp.escape(COMMAND_PREFIX)}(?<name>\S+)(\s*(?<arguments>.*))/

    # Events
    listen_to :connect, method: :on_connect
    listen_to :ctcp, method: :on_ctcp
    listen_to :join, method: :on_join
    listen_to :leaving, method: :on_leave
    listen_to :message, method: :on_message
    listen_to :nick, method: :on_nick

    private

    def bot_caused_event?(message)
      message.user == bot
    end

    def command_invocation?(message)
      sanitized_message = Sanitize(Unformat(message.message))
      sanitized_message.match?(COMMAND_PATTERN)
    end

    def on_connect(message)
      ConnectEvent.new(message).run
    end

    def on_ctcp(message)
      CtcpEvent.new(message).run
    end

    def on_join(message)
      JoinEvent.new(message).run
    end

    def on_leave(message)
      LeaveEvent.new(message).run
    end

    def on_message(message)
      unless bot_caused_event?(message)
        if command_invocation?(message)
          CommandEvent.new(message).run
        else
          MessageEvent.new(message).run
        end
      end
    end

    def on_nick(message)
      NickEvent.new(message).run
    end
  end
end
