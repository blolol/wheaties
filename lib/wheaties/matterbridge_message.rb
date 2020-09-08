require 'cinch/message'

module Wheaties
  class MatterbridgeMessage < ::Cinch::Message
    # Constants
    COMMAND_INVOCATION_PATTERN = /
      \A<(?<nick>.*?)>\s+
      #{CinchPlugin::COMMAND_PATTERN}
    /x

    def self.from(message)
      new(message.raw, message.bot)
    end

    def reply(text, prefix = false)
      text = text.to_s

      if @channel && prefix
        text = prefix_lines_with_bridged_nick(text)
      end

      reply_target.send(text)
    end

    def safe_reply(text, prefix = false)
      text = text.to_s

      if @channel && prefix
        text = prefix_lines_with_bridged_nick(text)
      end

      reply_target.safe_send(text)
    end

    private

    def bridged_nick
      @bridged_nick ||= message[COMMAND_INVOCATION_PATTERN, :nick]
    end

    def prefix_lines_with_bridged_nick(text)
      text.split("\n").map { |line| "#{bridged_nick}: #{line}" }.join("\n")
    end
  end
end
