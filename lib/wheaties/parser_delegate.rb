module Wheaties
  class ParserDelegate
    def initialize(message, stack:)
      @message = message
      @stack = stack
    end

    def call(command_name, arguments)
      command = find_command(command_name)
      CommandInvocation.new(@message, command, arguments, stack: @stack).result.ruby_value
    end

    private

    def built_in_command?(name)
      InvocationEnvironment.built_in_command?(name)
    end

    def find_command(name)
      if built_in_command?(name)
        BuiltInCommand.new(name)
      else
        Command.find_by_name(name)
      end
    end
  end
end
