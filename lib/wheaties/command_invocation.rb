module Wheaties
  class CommandInvocation
    attr_reader :arguments, :command, :event, :formats, :id, :message, :log_level, :stack
    delegate :name, to: :command

    def initialize(message, command, arguments = InvocationArguments.new, event: :command,
        formats:, log_level: :info, stack: [])
      @message = message
      @command = command
      @event = event
      @formats = formats
      @log_level = log_level
      @stack = stack
      @id = stack.size
      @arguments = if arguments.is_a?(InvocationArguments)
        arguments
      else
        InvocationArguments.new(arguments)
      end
    end

    def invoke
      result.reply_to_chat(message)
    end

    def result
      log_invocation
      command.invoke(environment)
    rescue SyntaxError => syntax_error
      SyntaxErrorResult.new(self, syntax_error)
    rescue => error
      ErrorResult.new(self, error)
    end

    private

    delegate :bot, to: :message
    delegate :loggers, to: :bot

    def environment
      InvocationEnvironment.new(self)
    end

    def log_invocation
      interpolations = {
        arguments: arguments.inspect,
        event: event,
        invocation_id: id,
        command_id: command.id,
        command_name: command.name,
        nick: message.user.nick,
        stack: stack.map(&:name).inspect,
        user: message.user.user
      }

      logger.debug('Invoking command nick=%{nick} user=%{user} invocation.id=%{invocation_id} ' \
        'command.name=%{command_name} command.id=%{command_id} arguments=%{arguments} ' \
        'event=%{event} stack=%{stack}' % interpolations)
    end
  end
end
