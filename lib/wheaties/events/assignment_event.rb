module Wheaties
  class AssignmentEvent
    def self.assignment_pattern(bot)
      /\A#{bot.nick}:\s*(?<name>\S*?)\s+is\s+(?<value>.*)\z/i
    end

    def initialize(message)
      @message = message
    end

    def run
      if value.blank?
        warn_about_blank_value
      else
        command.assign_value(value, @message)
      end
    end

    private

    def assignment_pattern
      self.class.assignment_pattern(@message.bot)
    end

    def build_command
      PlainTextCommand.new(created_by: @message.user.user, name: name)
    end

    def built_in_command?
      InvocationEnvironment.built_in_command?(name)
    end

    def command
      find_command || build_command
    end

    def command_invocation?
      unparsed_value.start_with?('[') && unparsed_value.end_with?(']')
    end

    def find_command
      if built_in_command?
        BuiltInCommand.new(name)
      else
        Command.where(name: name).first
      end
    end

    def match_data
      @match_data ||= sanitized_message.match(assignment_pattern)
    end

    def name
      match_data[:name]
    end

    def parsed_value
      @value_parsed = true

      if command_invocation?
        stringify(parser.parse(unparsed_value)&.first)
      else
        unparsed_value
      end
    end

    def parser
      ParserFactory.parser(@message)
    end

    def sanitized_message
      Cinch::Helpers.sanitize(Cinch::Formatting.unformat(@message.message))
    end

    def stringify(value)
      if value.is_a?(String)
        value
      elsif value.is_a?(Array)
        value.map { |element| stringify(element) }.join("\n")
      end
    end

    def unparsed_value
      match_data[:value]
    end

    def value
      if @value_parsed
        @value
      else
        @value = parsed_value
      end
    end

    def warn_about_blank_value
      if command_invocation?
        @message.reply("Sorry, your command returned a blank value, so I can't save “#{name}”.",
          true)
      else
        @message.reply("You need to give me something to assign to “#{name}”!", true)
      end
    end
  end
end
