module Wheaties
  class ConnectEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_001')
    end

    def event
      :connect
    end
  end
end
