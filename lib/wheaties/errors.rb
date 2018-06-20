module Wheaties
  class Error < ::StandardError; end

  class CommandNotFoundError < Error
    # Attributes
    attr_reader :command_name

    def initialize(command_name:)
      @command_name = command_name
    end
  end
end
