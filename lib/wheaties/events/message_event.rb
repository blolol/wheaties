module Wheaties
  class MessageEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_privmsg')
    end

    def event
      :message
    end
  end
end
