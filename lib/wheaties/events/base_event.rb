module Wheaties
  class BaseEvent
    class << self
      # Attributes
      attr_accessor :cache
    end

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

    def cache
      self.class.cache ||= EventCommandCache.new(legacy_grunt_event)
    end

    def commands
      cache.commands
    end

    def event
      raise('This method should be implemented by subclasses')
    end

    def legacy_grunt_event
      event
    end
  end
end
