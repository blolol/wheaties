module Wheaties
  module Discord
    module ChatBridge
      module Receive
        class ChatEvent
          # Return an instance of {ChatEvent} or one of its subclasses, depending on the type of the
          # event represented by the stream entry.
          def self.from_stream_entry(id, fields)
            new(id, fields)
          end

          def initialize(id, fields)
            @id = id
            @fields = fields
            @payload = JSON.parse(fields['payload'])
          end

          def deliver
            if ignore?
              logger.debug("Ignored event: id=#{id} payload=#{payload.inspect}")
              return
            end

            webhook.execute(webhook_payload)

            log_delivery
          rescue Wheaties::ChatBridge::ChannelMappingNotFoundError
            logger.error("Couldn't find a matching Discord channel in the chat bridge channel " \
              "mapping for event: id=#{id} payload=#{payload.inspect}")
          end

          private

          attr_reader :fields, :id, :payload

          def channel
            @channel ||= Wheaties::ChatBridge::ChatEventChannel.new(server, payload['channel'])
          end

          def channel_id
            channel.on('discord')['id']
          end

          def ignore?
            published_by_us?
          end

          def log_delivery
            logger.debug("Delivered event to Discord: id=#{id} payload=#{payload.inspect}")
          end

          def logger
            Wheaties.logger
          end

          def plain_text_webhook_payload
            {
              username: payload.dig('user', 'name'),
              content: payload['content']
            }
          end

          def published_by_us?
            server.platform.discord? && server.id == ENV['DISCORD_SERVER_ID']
          end

          def rich_webhook_payload
            payload.dig('representations', 'discord')
          end

          def server
            @server ||= Wheaties::ChatBridge::ChatEventServer.new(payload['server'])
          end

          def webhook
            Webhook.new(channel_id)
          end

          def webhook_payload
            rich_webhook_payload || plain_text_webhook_payload
          end
        end
      end
    end
  end
end
