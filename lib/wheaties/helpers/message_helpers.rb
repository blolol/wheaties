module Wheaties
  module MessageHelpers
    private

    def channel
      message.channel
    end

    def command?
      event == :command
    end

    def event?
      !command?
    end

    def history(target = nil)
      history_target = Target(target || message.target)
      CommandsPlugin.instance(bot).message_history.for(history_target)
    end

    def pm?
      !message.channel?
    end

    # Provided for legacy compatibility with existing commands.
    def response
      @response ||= ResponseShim.new(message)
    end

    # Provided for legacy compatibility with existing commands.
    def sender
      message.user
    end

    ResponseShim = Struct.new(:message) do
      def text
        message.message
      end
    end
  end
end
