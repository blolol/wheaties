module Wheaties
  class ParserFactory
    def self.parser(message, stack:, log_level: :info)
      delegate = ParserDelegate.new(message, stack: stack, log_level: log_level)
      Harby::Parser.new(delegate)
    end
  end
end
