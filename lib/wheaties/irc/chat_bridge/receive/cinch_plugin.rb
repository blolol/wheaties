module Wheaties
  module Irc
    module ChatBridge
      module Receive
        class CinchPlugin
          include Cinch::Plugin

          listen_to :connect, method: :on_connect

          private

          def on_connect(event)
            stream.each_entry do |id, fields|
              ChatEvent.from_stream_entry(id, fields).deliver
            end
          end

          def stream
            @stream ||= Wheaties::ChatBridge::Stream.new
          end
        end
      end
    end
  end
end
