module Wheaties
  class CinchPlugin
    include Cinch::Plugin

    # Constants
    COMMAND_PREFIX = ENV.fetch('COMMAND_PREFIX', '.')
    COMMAND_PATTERN = /
      #{Regexp.escape(COMMAND_PREFIX)}
      (?<name>
        (?!#{Regexp.escape(COMMAND_PREFIX)}) # Command name cannot start with the prefix
        \S+
      )
      (\s*(?<arguments>.*))
    /x
    COMMAND_INVOCATION_PATTERN = /\A#{COMMAND_PATTERN}/

    # Events
    listen_to :connect, method: :on_connect
    listen_to :ctcp, method: :on_ctcp
    listen_to :join, method: :on_join
    listen_to :leaving, method: :on_leave
    listen_to :message, method: :on_message
    listen_to :nick, method: :on_nick

    def self.instance(bot)
      bot.plugins.find { |plugin| plugin.class == Wheaties::CinchPlugin }
    end

    def message_history
      @message_history ||= MessageHistory.new(bot)
    end

    private

    def assignment_pattern
      AssignmentEvent.assignment_pattern(bot)
    end

    def bot_caused_event?(message)
      message.user == bot
    end

    def matterbridge_command_invocation?(message)
      message.user.user == ENV['MATTERBRIDGE_USER'] &&
        sanitize_message(message).match?(MatterbridgeMessage::COMMAND_INVOCATION_PATTERN)
    end

    def command_assignment?(message)
      sanitize_message(message).match?(assignment_pattern)
    end

    def command_invocation?(message)
      irc_command_invocation?(message) || matterbridge_command_invocation?(message)
    end

    def irc_command_invocation?(message)
      sanitize_message(message).match?(COMMAND_INVOCATION_PATTERN)
    end

    def log_error_and_notify_bugsnag(error, message)
      exception(error)
      BugsnagNotifier.new(error, message).notify
    end

    def on_connect(message)
      ConnectEvent.new(message).run
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def on_ctcp(message)
      unless bot_caused_event?(message)
        CtcpEvent.new(message).run
      end
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def on_join(message)
      unless bot_caused_event?(message)
        JoinEvent.new(message).run
      end
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def on_leave(message, user)
      unless bot_caused_event?(message)
        LeaveEvent.new(message).run
      end
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def on_message(message)
      unless bot_caused_event?(message)
        if irc_command_invocation?(message)
          CommandEvent.new(message).run
        elsif respond_to_matterbridge_commands? && matterbridge_command_invocation?(message)
          matterbridge_message = MatterbridgeMessage.from(message)
          CommandEvent.new(matterbridge_message).run
        elsif command_assignment?(message)
          AssignmentEvent.new(message).run
        else
          MessageEvent.new(message).run
        end
      end
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def on_nick(message)
      unless bot_caused_event?(message)
        NickEvent.new(message).run
      end
    rescue => error
      log_error_and_notify_bugsnag(error, message)
    end

    def respond_to_matterbridge_commands?
      ENV.include?('MATTERBRIDGE_USER')
    end

    def sanitize_message(message)
      Sanitize(Unformat(message.message))
    end
  end
end
