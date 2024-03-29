module Wheaties
  module CommandHelpers
    private

    def builtins
      InvocationEnvironment::BUILT_IN_COMMANDS.sort.join(', ')
    end

    def env
      Wheaties.env
    end

    # Halts execution of the current command, returning an optional value.
    def halt(return_value = nil)
      throw(stack.last, return_value)
    end

    # Halts execution of the entire stack, even from within a nested command, returning an
    # optional value.
    def halt!(return_value = nil)
      throw(stack.first, return_value)
    end

    def match
      stack.last.command.find_by_regex_match_data
    end

    # Treats the currently-executing command's first argument as a subcommand, and attempts to
    # find and run a command with the name of the currently-executing command, plus the subcommand,
    # joined by an underscore. For example, if the currently-executing command's name is "foo",
    # and the user executes ".foo bar", `subcommands!` will look for a command named "foo_bar". The
    # rest of the arguments are passed to the subcommand.
    def subcommands!(&block)
      if args.first.to_s.match?(/\A[a-zA-Z0-9_-]+\z/)
        SubcommandInvocation.new(message, args, stack).invoke(&block)
      end
    end

    # Returns true if the currently-executing command is at the top of the stack, i.e. it was the
    # first command executed by the user or event.
    def top?
      stack.size == 1
    end
  end
end
