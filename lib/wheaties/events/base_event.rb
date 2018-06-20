module Wheaties
  class BaseEvent
    def initialize(message)
      @message = message
    end

    def run
      arguments = []

      commands.each do |command|
        CommandInvocation.new(@message, command, arguments, event: event).invoke
      end
    end

    private

    def commands
      raise('This method should be implemented by subclasses')
    end

    def event
      raise('This method should be implemented by subclasses')
    end
  end
end
