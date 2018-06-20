module Wheaties
  class ParserDelegate
    def initialize(message)
      @message = message
    end

    def call(command_name, arguments)
      command = Command.find_by_name(command_name)
      CommandInvocation.new(@message, command, arguments).result.ruby_value
    end
  end
end
