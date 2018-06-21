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

    def assignment_pattern
      AssignmentEvent.assignment_pattern(bot)
    end

    def bot_caused_event?(message)
      message.user == bot
    end

    def command_assignment?(message)
      sanitize_message(message).match?(assignment_pattern)
    end

    def command_invocation?(message)
      sanitize_message(message).match?(COMMAND_PATTERN)
    end

    def notify_bugsnag(error, message)
      BugsnagNotifier.new(error, message).notify
    end

    def on_connect(message)
      ConnectEvent.new(message).run
    rescue => error
      notify_bugsnag(error, message)
    end

    def on_ctcp(message)
      unless bot_caused_event?(message)
        CtcpEvent.new(message).run
      end
    rescue => error
      notify_bugsnag(error, message)
    end

    def on_join(message)
      unless bot_caused_event?(message)
        JoinEvent.new(message).run
      end
    rescue => error
      notify_bugsnag(error, message)
    end

    def on_leave(message)
      unless bot_caused_event?(message)
        LeaveEvent.new(message).run
      end
    rescue => error
      notify_bugsnag(error, message)
    end

    def on_message(message)
      unless bot_caused_event?(message)
        if command_invocation?(message)
          CommandEvent.new(message).run
        elsif command_assignment?(message)
          AssignmentEvent.new(message).run
        else
          MessageEvent.new(message).run
        end
      end
    rescue => error
      notify_bugsnag(error, message)
    end

    def on_nick(message)
      unless bot_caused_event?(message)
        NickEvent.new(message).run
      end
    rescue => error
      notify_bugsnag(error, message)
    end

    def sanitize_message(message)
      Sanitize(Unformat(message.message))
    end
  end
end
