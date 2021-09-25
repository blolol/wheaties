module Wheaties
  class ParserFactory
    def self.parser(message, stack:)
      delegate = ParserDelegate.new(message, stack: stack)
      Harby::Parser.new(delegate)
    end
  end
end
