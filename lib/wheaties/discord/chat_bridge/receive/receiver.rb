module Wheaties
  module Discord
    module ChatBridge
      module Receive
        class Receiver
          def start
            stream.each_entry do |id, fields|
              ChatEvent.from_stream_entry(id, fields).deliver
            end
          end

          private

          def logger
            Wheaties.logger
          end

          def stream
            @stream ||= Wheaties::ChatBridge::Stream.new
          end
        end
      end
    end
  end
end
