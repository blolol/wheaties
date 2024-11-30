module Wheaties
  module Irc
    module ChatBridge
      module Transmit
        class CinchPlugin
          include Cinch::Plugin

          listen_to :join, method: :on_join
          listen_to :leaving, method: :on_leave
          listen_to :message, method: :on_message

          private

          def ignore?(event)
            self?(event) || relaymsg?(event)
          end

          def on_join(event)
            return if ignore?(event)
            content = "#{event.user.nick} joined #{event.channel.name}"
            StreamEntry.new(type: 'irc:join', event: event, content: content).publish
          end

          def on_leave(event, user)
            return if ignore?(event)
            content = "#{event.user.nick} left #{event.channel.name}"
            StreamEntry.new(type: 'irc:leave', event: event, content: content).publish
          end

          def on_message(event)
            return if ignore?(event)
            StreamEntry.new(type: 'irc:message', event: event, content: event.message).publish
          end

          def relaymsg?(event)
            event.user.nick.include?('/')
          end

          def self?(event)
            event.user.authname == bot.authname
          end
        end
      end
    end
  end
end
