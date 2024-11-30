module Wheaties
  module Irc
    module ChatBridge
      module Receive
        class DiscordEvent < ChatEvent
          NICK_SUFFIX = '/Discord'
          AVAILABLE_NICK_BYTES = ChatEvent::MAX_NICK_LENGTH_BYTES - NICK_SUFFIX.bytesize

          private

          def sanitized_discord_name
            discord_name = payload.dig('user', 'name')
            sanitized_name = Cinch::Helpers.sanitize(discord_name) # Remove unprintable chars
            sanitized_name.gsub!(/\s/, '_') # Replace whitespace with underscores
            trim_multibyte_nick(sanitized_name) # Trim to AVAILABLE_NICK_BYTES
          end

          def spoofed_nick
            super.presence || (sanitized_discord_name << NICK_SUFFIX)
          end

          def spoofed_nick?
            true
          end

          # Trims `nick` to, at most, {AVAILABLE_NICK_BYTES} bytes long while preserving multibyte
          # characters in the input.
          def trim_multibyte_nick(nick)
            return nick if nick.bytesize <= AVAILABLE_NICK_BYTES

            index = 0
            bytes = 0
            chars = nick.chars

            while index < chars.length
              char_bytes = chars[index].bytesize
              break if bytes + char_bytes > AVAILABLE_NICK_BYTES
              bytes += char_bytes
              index += 1
            end

            nick[0...index]
          end
        end
      end
    end
  end
end
