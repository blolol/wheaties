module Wheaties
  module Irc
    module ChatBridge
      class CinchPlugin
        include Cinch::Plugin

        listen_to :join, method: :on_join
        listen_to :leaving, method: :on_leave
        listen_to :message, method: :on_message

        private

        def on_join(event)
          content = "#{event.user.nick} joined #{event.channel.name}"
          StreamEntry.new(type: 'irc:join', event: event, content: content).publish
        end

        def on_leave(event, user)
          content = "#{event.user.nick} left #{event.channel.name}"
          StreamEntry.new(type: 'irc:leave', event: event, content: content).publish
        end

        def on_message(event)
          StreamEntry.new(type: 'irc:message', event: event, content: event.message).publish
        end
      end
    end
  end
end
