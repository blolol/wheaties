module Wheaties
  class BaseEvent
    class << self
      # Attributes
      attr_accessor :cache
    end

    def initialize(message)
      @message = message
      @thread_group = ThreadGroup.new
    end

    def run
      commands.each { |command| invoke_command_in_thread(command) }
      @thread_group.enclose
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

    def invoke_command_in_thread(command)
      arguments = []

      thread = Thread.new do
        CommandInvocation.new(@message, command, arguments, event: event).invoke
      end

      @thread_group.add(thread)
    end

    def legacy_grunt_event
      event
    end
  end
end
