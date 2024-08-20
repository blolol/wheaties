module Wheaties
  class SubcommandInvocation
    def initialize(message, arguments, stack)
      @message = message
      @arguments = arguments
      @stack = stack.dup
    end

    def invoke
      result.ruby_value
    rescue CommandNotFoundError => not_found_error
      if block_given?
        yield subcommand_name
      else
        raise not_found_error
      end
    end

    private

    def command_invocation
      CommandInvocation.new(@message, subcommand, subcommand_arguments, stack: @stack)
    end

    def parent_command_name
      @stack.last.name
    end

    def result
      command_invocation.result
    end

    def subcommand
      Command.find_by_name(subcommand_name)
    end

    def subcommand_name
      "#{parent_command_name}_#{@arguments.first.to_s.downcase}"
    end

    def subcommand_arguments
      InvocationArguments.new(@arguments[1..-1])
    end
  end
end
