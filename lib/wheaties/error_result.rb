module Wheaties
  class ErrorResult
    # Constants
    EMOJI = %w(🤮 😱 😫 😬 ☹️ 😧 🤢 😵 🤕 🤯 😢 😭 💩 🙊 🌚)

    def self.emoji
      EMOJI.sample
    end

    def initialize(invocation, error)
      @invocation = invocation
      @error = error
    end

    def reply_to_chat(message)
      @message = message

      if internal_error?
        log_error
        notify_bugsnag
        alert_channel_about_internal_error
      else
        notify_bugsnag(severity: 'info') if event?
        alert_channel_or_log_error
      end
    end

    def ruby_value
      nil
    end

    private

    def a_or_an
      if 'AEIOU'.include?(error_class_name[0])
        'An'
      else
        'A'
      end
    end

    def alert?
      !!detail_target
    end

    def alert_channel
      if event?
        event_command_updater.safe_send("#{self.class.emoji} #{a_or_an} #{error_class_name} was " \
          "raised on line #{most_recent_trace.lineno} of “#{most_recent_trace.path}” while " \
          "running “#{event_command.name}”, which was last updated by you.")
      else
        @message.safe_reply("#{self.class.emoji} #{a_or_an} #{error_class_name} was raised on " \
          "line #{most_recent_trace.lineno} of “#{most_recent_trace.path}”. I'll PM you more " \
          'details.', true)
      end

      send_more_details_to_user
    end

    def alert_channel_about_internal_error
      unless event?
        @message.reply("#{self.class.emoji} #{a_or_an} #{error_class_name} was raised in my " \
          'code. The proper authorities have been notified so that it can be fixed. ' \
          "(Error ID: #{error_uuid})", true)
      end
    end

    def alert_channel_or_log_error
      if alert?
        alert_channel
      else
        log_error
      end
    end

    def bot
      @message.bot
    end

    def detail_target
      if event?
        event_command_updater
      else
        @message.user
      end
    end

    def command_exists?(name)
      Command.where(name: name).exists?
    end

    def command_url(command, line:)
      "#{command.url}\#L#{line}"
    end

    def error_class_name
      @error.class.name
    end

    def error_uuid
      @error_uuid ||= SecureRandom.uuid
    end

    def event?
      @invocation.event != :command
    end

    def event_command
      @event_command ||= @invocation.stack.first
    end

    def event_command_updater
      bot.user_list.find(event_command.updated_by)
    end

    def internal_error?
      relevant_traces.empty?
    end

    def log_error
      @error.full_message(highlight: false).each_line do |line|
        @message.bot.loggers.log("[#{error_uuid}] #{line}", :exception, :error)
      end
    end

    def most_recent_trace
      @most_recent_trace ||= relevant_traces.last
    end

    def notify_bugsnag(severity: 'warning')
      wheaties_tab = {
        command_stack: @invocation.stack.map(&:name),
        error_id: error_uuid,
        event: @invocation.event
      }

      BugsnagNotifier.new(@error, @message, severity: severity, wheaties_tab: wheaties_tab).notify
    end

    def send_more_details_to_user
      detail_target.safe_send("Here's the trace of the #{error_class_name} that occurred " \
        '(most recent last):')

      index = 1

      relevant_traces[0..-2].each do |trace|
        trace_message = "#{index}. Line #{trace.lineno} in “#{trace.path}”"

        if command_exists?(trace.path)
          command = Command.find_by_name(trace.path)
          trace_message << " #{command_url(command, line: trace.lineno)}"
        end

        detail_target.safe_send(trace_message)

        index += 1
      end

      # Include error message with last trace
      trace_message = "#{index}. #{error_class_name} on line #{most_recent_trace.lineno} in " \
        "“#{most_recent_trace.path}”: #{@error.message}"

      if command_exists?(most_recent_trace.path)
        command = Command.find_by_name(most_recent_trace.path)
        trace_message << " #{command_url(command, line: most_recent_trace.lineno)}"
      end

      detail_target.safe_send(trace_message)
    end

    def relevant_traces
      @relevant_traces ||= @error.backtrace_locations.select do |location|
        !location.path.starts_with?('/') && location.path != '(eval)'
      end.reverse
    end
  end
end
