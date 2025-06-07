module Wheaties
  class MessageEvent < BaseEvent
    private

    def event
      :message
    end

    def legacy_grunt_event
      :on_privmsg
    end
  end
end
