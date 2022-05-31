module Wheaties
  class CommandEvent
    def initialize(message)
      @message = message
    end

    def run
      result.reply_to_chat(@message)
    end

    private

    def built_in_command?
      InvocationEnvironment.built_in_command?(command_name)
    end

    def command
      if built_in_command?
        BuiltInCommand.new(command_name)
      else
        Command.find_by_name(command_name)
      end
    end

    def command_invocation
      CommandInvocation.new(@message, command, parsed_arguments, stack: stack)
    end

    def command_name
      match_data[:name]
    end

    def match_data
      @match_data ||= sanitized_message.match(CommandsPlugin::COMMAND_PATTERN)
    end

    def parsed_arguments
      parser.parse(unparsed_arguments) || []
    end

    def parser
      ParserFactory.parser(@message, stack: stack)
    end

    def result
      command_invocation.result
    rescue CommandNotFoundError => not_found_error
      CommandNotFoundResult.new(not_found_error.command_name)
    end

    def sanitized_message
      Cinch::Helpers.sanitize(Cinch::Formatting.unformat(@message.message))
    end

    def stack
      @stack ||= []
    end

    def unparsed_arguments
      match_data[:arguments]
    end
  end
end
