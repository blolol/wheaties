module Wheaties
  module Irc
    module ChatBridge
      module Transmit
        class StreamEntry < Wheaties::ChatBridge::StreamEntry
          private

          def channel_payload
            {
              name: channel_name,
              type: channel_type
            }
          end

          def channel_name
            event.channel? ? event.channel.name : event.user.nick
          end

          def channel_type
            event.channel? ? 'channel' : 'dm'
          end

          def server_payload
            {
              platform: 'irc',
              name: ENV['IRC_SERVER']
            }
          end

          def user_payload
            {
              name: event.user.nick,
              host: event.user.host,
              user: event.user.user,
              realname: event.user.realname,
              authname: event.user.authname
            }
          end
        end
      end
    end
  end
end
