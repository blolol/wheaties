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
      assert_equal "Hello", parse(".Hello world").name
    end
    
    def test_arguments
      assert_argument_count 0, parse(".hello")
      assert_argument_count 1, parse(".hello world")
      assert_argument_count 2, parse(".hello world {literal string}")
      assert_argument_count 1, parse(".hello [puts world {literal string}]")
      assert_argument_count 2, parse(%q{.test well "hello [method with {some} "args"] world"})
    end
    
    def test_word
      assert_equal "world", parse(".hello world").arguments[0].eval
      assert_equal "baz", parse(".foo bar baz").arguments[1].eval
      assert_equal "bar_baz", parse(".foo bar_baz").arguments[0].eval
      assert_equal "BarB4z", parse(".foo BarB4z").arguments[0].eval
    end
    
    def test_literal
      assert_equal "with a literal string", parse(".test {with a literal string}").arguments[0].eval
      assert_equal "second", parse(".test first {second}").arguments[1].eval
      assert_equal "{literal", parse(".test {{literal} word").arguments[0].eval
      assert_equal "¬ø†ß øƒ ß¥µ∫ø¬ß", parse(".test {¬ø†ß øƒ ß¥µ∫ø¬ß}").arguments[0].eval
      assert_equal "so[me wo]rds", parse(".test {so[me wo]rds}").arguments[0].eval
      assert_equal %q{so"me wo"rds}, parse(%q{.test {so"me wo"rds}}).arguments[0].eval
    end
    
    def test_interpolated
      assert_equal "quick brown fox", parse(%q{.test "quick brown fox"}).arguments[0].eval
      assert_equal "hello ", parse(%q{.test "hello [world]"}).arguments[0].eval
      assert_equal "hello world", parse(%q{.test "hello[method] world"}).arguments[0].eval
      assert_equal "hello  world", parse(%q{.test "hello [method] world"}).arguments[0].eval
    end
  end
end
