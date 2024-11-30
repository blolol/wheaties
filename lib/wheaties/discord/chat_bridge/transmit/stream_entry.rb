module Wheaties
  module Discord
    module ChatBridge
      module Transmit
        class StreamEntry < Wheaties::ChatBridge::StreamEntry
          private

          def channel_payload
            {
              name: event.channel.name,
              id: event.channel.id.to_s,
              type: channel_type
            }
          end

          def channel_type
            event.channel.class::TYPES.find do |name, id|
              id == event.channel.type
            end.first
          end

          def server_payload
            {
              platform: 'discord',
              name: event.server.name,
              id: event.server.id.to_s
            }
          end

          def user_payload
            {
              name: event.user.display_name,
              id: event.user.id.to_s
            }
          end
        end
      end
    end
  end
end
