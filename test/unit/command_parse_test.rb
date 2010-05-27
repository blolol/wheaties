begin
  require "test_helper"
  require "polyglot"
  require "treetop"
  require "grunt/command_node_classes"
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
    
    def assert_argument_count(count, command)
      assert_equal count, command.arguments.size
    end
    
    def test_name
      assert_equal "hello", parse(".hello").name
      assert_equal "hello_world", parse(".hello_world").name
      assert_equal "2hot", parse(".2hot").name
      assert_equal "print", parse(%q{.print "hello [world]"}).name
    end
    
    def test_arguments
      assert_argument_count 0, parse(".hello")
      assert_argument_count 1, parse(".hello world")
      assert_argument_count 2, parse(".hello world {literal string}")
      assert_argument_count 1, parse(".hello [puts world {literal string}]")
    end
    
    def test_literal
      assert_equal "with a literal string", parse(".test {with a literal string}").arguments[0].eval
      assert_equal "second", parse(".test first {second}").arguments[1].eval
      assert_equal "{literal", parse(".test {{literal} word").arguments[0].eval
      assert_equal "¬ø†ß øƒ ß¥µ∫ø¬ß", parse(".test {¬ø†ß øƒ ß¥µ∫ø¬ß}").arguments[0].eval
    end
  end
end
