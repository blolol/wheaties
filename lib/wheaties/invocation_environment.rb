module Wheaties
  class InvocationEnvironment
    include Cinch::Helpers
    include CdnHelpers
    include CommandHelpers
    include DocumentationHelpers
    include FormattingHelpers
    include LoggingHelpers
    include MessageHelpers
    include StorageHelpers
    include VersionHelpers

    # Constants
    BUILT_IN_COMMANDS = %i(b bold builtins co color decrement del env get help hget hset i increment
      invert inv italic jget jset pl plain set uf underline ul unformat version) +
      FormattingHelpers::COLORS

    def self.built_in_command?(name)
      BUILT_IN_COMMANDS.include?(name.downcase.to_sym)
    end

    def initialize(invocation)
      @invocation = invocation
    end

    def args
      arguments
    end

    def eval(command)
      update_command_usage_stats(command)

      stack << invocation
      eval_file_name = command.name

      catch(invocation) do
        Kernel.eval(command.body, context, eval_file_name)
      end
    rescue UncaughtThrowError => error
      if stack.include?(error.tag)
        # This should have been caught by `catch(invocation)` in the method body,
        # so log the unexpected error, then continue
        logger.warn("#{error.class.name} in InvocationEnvironment#eval: " \
          "no catch handler for #{error.tag}")
      else
        raise error
      end
    end

    def invoke_built_in_command(method_name)
      return_value = send(method_name, *arguments)
      RubyInvocationResult.new(return_value)
    end

    def method_missing(name, *arguments)
      command = Command.find_by_name(name)
      CommandInvocation.new(message, command, arguments, event: event,
        formats: [:ruby] + invocation.formats, stack: stack).result.ruby_value
    rescue CommandNotFoundError
      super
    end

    private

    attr_reader :invocation
    delegate :arguments, :event, :log_level, :message, :stack, to: :invocation
    delegate :bot, to: :message

    def context
      binding
    end

    def msg
      message
    end

    def respond_to
      response_collector = ResponseCollector.new
      yield response_collector
      response_collector.respond!(message, *invocation.formats)
    end

    def update_command_usage_stats(command)
      command.update_usage_stats(used_by: message.user.nick)
    end
  end
end
