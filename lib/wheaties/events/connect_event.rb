module Wheaties
  class ConnectEvent < BaseEvent
    private

    # Since this event is only triggered once, when the bot starts up, we don't want to use
    # EventCommandCache and keep references to the commands around in memory indefinitely. So we
    # load them once here and let them get garbage collected.
    def commands
      Command.where(events: 'on_001')
    end

    def event
      :connect
    end
  end
end
