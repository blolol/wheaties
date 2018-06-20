module Wheaties
  class CommandInvocation
    # Attributes
    attr_reader :arguments, :command, :event, :message, :stack

    def initialize(message, command, arguments = [], event: :command, stack: [])
      @message = message
      @command = command
      @arguments = arguments
      @event = event
      @stack = stack.dup
    end

    def invoke
      result.reply_to_chat(@message)
    end

    def result
      log_invocation
      @command.invoke(environment)
    rescue SyntaxError => syntax_error
      SyntaxErrorResult.new(self, syntax_error)
    rescue => error
      ErrorResult.new(self, error)
    end

    private

    def bot
      @message.bot
    end

    def environment
      InvocationEnvironment.new(@message, @arguments, event: @event, stack: @stack)
    end

    def log_invocation
      interpolations = {
        arguments: @arguments.inspect,
        event: @event,
        id: @command.id,
        name: @command.name,
        nick: @message.user.nick,
        stack: @stack.map(&:name).inspect,
        user: @message.user.user
      }

      logger.debug('Invoking command nick=%{nick} user=%{user} name=%{name} id=%{id} ' \
        'arguments=%{arguments} event=%{event} stack=%{stack}' % interpolations)
    end

    def logger
      bot.loggers
    end
  end
end
