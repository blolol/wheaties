module Wheaties
  module Irc
    module ChatBridge
      module Receive
        class ChatEvent
          # The maximum length of nicknames accepted by our IRC server, in bytes.
          MAX_NICK_LENGTH_BYTES = 32

          # A {Regexp} matching an IRC nickname that requires use of the `RELAYMSG` command to spoof
          # the nick. Our IRC server requires the presence of a "discriminator" character (we use
          # `/`) somewhere in the middle of the nick.
          VALID_RELAYMSG_NICK_PATTERN = /\A\S+\/\S+\z/

          attr_reader :fields, :id, :payload

          # Return an instance of {ChatEvent} or one of its subclasses, depending on the type of
          # the event represented by the stream entry.
          def self.from_stream_entry(id, fields)
            klass = case fields['type'].split(':')
            in ['discord', *]
              DiscordEvent
            else
              self
            end

            klass.new(id, fields)
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

            case type
            when 'action' then deliver_action
            when 'message' then deliver_message
            when 'notice' then deliver_notice
            else
              logger.warn("Invalid chat bridge IRC event type: type=#{type.inspect} id=#{id} " \
                "payload=#{payload.inspect}")
            end

            log_delivery
          end

          private

          def bot
            Wheaties.bot
          end

          def channel
            @channel ||= Channel.new(server, payload['channel'])
          end

          def content
            payload.dig('representations', 'irc', 'content') || payload['content']
          end

          def deliver_action
            if spoofed_nick?
              target.action(content, as: spoofed_nick)
            else
              target.action(content)
            end
          end

          def deliver_message
            if spoofed_nick?
              target.send(content, as: spoofed_nick)
            else
              target.send(content)
            end
          end

          def deliver_notice
            target.notice(content)
          end

          def ignore?
            published_by_us?
          end

          def log_delivery
            logger.debug("Delivered event to IRC: id=#{id} target=#{target.name} " \
              "payload=#{payload.inspect}")
          end

          def logger
            Wheaties.logger
          end

          # Returns true if this event was published by us.
          def published_by_us?
            server.platform.irc? && server.name == ENV['IRC_SERVER']
          end

          def server
            @server ||= Server.new(payload['server'])
          end

          def spoofed_nick
            payload.dig('representations', 'irc', 'nick')
          end

          def spoofed_nick?
            spoofed_nick.present? && spoofed_nick =~ VALID_RELAYMSG_NICK_PATTERN &&
              spoofed_nick.bytesize <= MAX_NICK_LENGTH_BYTES
          end

          def target
            @target ||= Cinch::Target.new(channel.irc_name, bot)
          end

          def type
            payload.dig('representations', 'irc', 'type') || 'message'
          end

          class ChannelMappingError < ::StandardError; end

          class Channel
            CHANNEL_MAPPINGS_COMMAND_NAME = 'chat_bridge_channels'.freeze

            attr_reader :source_attributes, :source_server

            def initialize(source_server, source_attributes)
              @source_server = source_server
              @source_attributes = source_attributes
            end

            def irc_name
              mapping.dig('irc', 'name')
            end

            private

            def mapping
              @mapping ||= mappings.find do |id, platforms|
                platforms.dig(source_platform.to_s, 'name') == source_name || id == source_name
              end&.last || mapping_not_found!
            end

            def mapping_not_found!
              raise ChannelMappingError, "Couldn't find a mapping for the #{source_platform} " \
                "channel #{source_attributes.inspect}"
            end

            def mappings
              @mappings ||= YAML.safe_load(Command.find_by_name(CHANNEL_MAPPINGS_COMMAND_NAME).body)
            rescue Wheaties::CommandNotFoundError
              raise ChannelMappingError, "Couldn't load the #{CHANNEL_MAPPINGS_COMMAND_NAME} command"
            end

            def source_name
              source_attributes['name']
            end

            def source_platform
              source_server.platform
            end
          end

          class Server
            attr_reader :attributes

            def initialize(attributes)
              @attributes = attributes
            end

            def name
              attributes['name']
            end

            def platform
              @platform ||= ActiveSupport::StringInquirer.new(attributes['platform'])
            end
          end
        end
      end
    end
  end
end
