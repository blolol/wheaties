module Wheaties
  class CommandInvocation
    # Attributes
    attr_reader :arguments, :command, :event, :id, :message, :stack

    def initialize(message, command, arguments = [], event: :command, stack: [])
      @message = message
      @command = command
      @arguments = arguments
      @event = event
      @stack = stack
      @id = stack.size
    end

    def invoke
      result.reply_to_chat(message)
    end

    def name
      command.name
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

    def bot
      message.bot
    end

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
        stack: stack.map(&:to_s).inspect,
        user: message.user.user
      }

      logger.debug('Invoking command nick=%{nick} user=%{user} invocation.id=%{invocation_id} ' \
        'command.name=%{command_name} command.id=%{command_id} arguments=%{arguments} ' \
        'event=%{event} stack=%{stack}' % interpolations)
    end

    def logger
      bot.loggers
    end
  end
end
