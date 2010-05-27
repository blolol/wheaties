begin
  require "test_helper"
  require "polyglot"
  require "treetop"
  require "grunt/command"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

module Grunt
  class CommandParseTest < Test::Unit::TestCase
    def setup
      @parser = CommandParser.new
    end
    
    def parse(input)
      result = @parser.parse(input)
      puts @parser.terminal_failures.join("\n") unless result
      assert !result.nil?
      result
    end
  end
end
