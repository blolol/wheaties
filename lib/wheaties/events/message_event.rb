module Wheaties
  class MessageEvent < BaseEvent
    def run
      super
      wait_for_threads_to_finish
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
