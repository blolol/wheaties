module Wheaties
  class SyntaxErrorResult < ErrorResult
    # Constants
    SYNTAX_ERROR_PATTERN = /^(?<command_name>.+):(?<line_number>\d+): syntax error, (?<message>.*)$/

    def initialize(invocation, error)
      super
      parse_error_message
    end

    def reply_to_chat(message)
      @message = message

      notify_bugsnag

      if event?
        event_command_updater&.safe_send(event_explanation)
      else
        @message.safe_reply(command_explanation, true)
      end
    end

    private

    def command_explanation
      if parsed?
        "#{emoji} There's a Ruby syntax error on line #{@line_number} of “#{@command_name}”: " \
          "#{@error_message}"
      else
        "#{emoji} There's a Ruby syntax error in #{@error.message.lines.first}"
      end
    end

    def command_with_syntax_error
      Command.find_by_name(@command_name)
    end

    def event_explanation
      if parsed?
        if @command_name == event_command.name
          "#{emoji} “#{event_command.name}”, last updated by you, was just run automatically in " \
            "response to an event, and a Ruby syntax error was raised on line #{@line_number}: " \
            "#{@error_message} #{event_command.url}"
        else
          "#{emoji} “#{event_command.name}”, last updated by you, was just run automatically in " \
            "response to an event, and a Ruby syntax error was raised on line #{@line_number} of " \
            "#{@command_name}: #{@error_message} #{command_with_syntax_error.url}"
        end
      else
        "#{emoji} “#{event_command.name}”, last updated by you, was just run automatically in " \
          'response to an event, and a Ruby syntax error was raised: ' \
          "#{@error.message.lines.first} #{event_command.url}"
      end
    end

    def notify_bugsnag
      super(severity: 'info')
    end

    def parse_error_message
      match_data = @error.message.match(SYNTAX_ERROR_PATTERN)

      @command_name = match_data[:command_name]
      @line_number = match_data[:line_number]
      @error_message = match_data[:message]
    end

    def parsed?
      @command_name && @line_number && @error_message
    end
  end
end
