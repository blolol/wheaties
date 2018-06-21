module Wheaties
  class ParserFactory
    def self.parser(message)
      delegate = ParserDelegate.new(message)
      Harby::Parser.new(delegate)
    end
  end
end
