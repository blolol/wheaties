module Wheaties
  class MessageEvent < BaseEvent
    def run
      super
      message_history.push(@message)
    end

    private

    def event
      :message
    end

    def legacy_grunt_event
      :on_privmsg
    end

    def message_history
      plugin.message_history
    end

    def plugin
      CinchPlugin.instance(@message.bot)
    end
  end
end
