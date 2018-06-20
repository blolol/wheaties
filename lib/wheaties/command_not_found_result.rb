module Wheaties
  class CommandNotFoundResult
    def initialize(command_name)
      @command_name = command_name
    end

    def reply_to_chat(message)
      message.safe_reply("I don't have a command called “#{@command_name}”.", true)
    end
  end
end
