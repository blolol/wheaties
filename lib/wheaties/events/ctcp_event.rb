module Wheaties
  class CtcpEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_ctcp')
    end

    def event
      :ctcp
    end
  end
end
