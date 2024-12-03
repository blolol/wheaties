module Wheaties
  module Discord
    module ChatBridge
      module Transmit
        module EventContainer
          extend Discordrb::EventContainer

          message do |event|
            next if EventFilter.new(event).ignore?
            StreamEntry.new(type: 'discord:message', event: event, content: event.content).publish
          end
        end
      end
    end
  end
end
