begin
  require "test_helper"
  require "polyglot"
  require "treetop"
  require "grunt/arguments.rb"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

Treetop.load(File.join(File.dirname(__FILE__), "..", "..", "lib", "grunt", "arguments"))

module Arguments
  class MethodNode
    def eval!(locals = {})
      args.map { |arg| arg.eval! }.join(" ")
    end
  end
end

module Grunt
  class ArgumentsTest < Test::Unit::TestCase
    def parse(input)
      result = @parser.parse(input)
      puts @parser.terminal_failures.join("\n") unless result
      result.should be_instance_of(Arguments::ArgumentsNode)
      result
    end
    
    custom_matcher :have do |receiver, matcher, args|
      count = args[0]
      something = matcher.chained_messages[0].name
      actual = receiver.send(something).size
      matcher.positive_failure_message = "Expected #{receiver.inspect} to have #{count} #{something}, but it had #{actual}"
      matcher.negative_failure_message = "Expected #{receiver.inspect} not to have #{count} #{something}, but it did"
      actual == count
    end
    
    custom_matcher :eval_to do |receiver, matcher, args|
      expected = args[0]
      actual = receiver.eval!
      matcher.positive_failure_message = "Expected #{actual.inspect} to be #{expected.inspect}, but it wasn't"
      matcher.negative_failure_message = "Expected #{actual.inspect} not to be #{expected.inspect}, but it was"
      actual == expected
    end
    
    custom_matcher :eval_to_instance_of do |receiver, matcher, args|
      expected = args[0]
      actual = receiver.eval!.class
      matcher.positive_failure_message = "Expected #{actual.name} to be an instance of #{expected.name}, but it wasn't"
      matcher.negative_failure_message = "Expected #{actual.name} not to be an instance of #{expected.name}, but it was"
      actual == expected
    end
    
    context "An ArgumentsParser instance" do
      setup do
        @parser = ArgumentsParser.new
      end
      
      should "parse words" do
        result = parse "foo bar baz"
        result.should have(3).args
        result.args[0].should eval_to("foo")
        result.args[1].should eval_to("bar")
        result.args[2].should eval_to("baz")
      end
      
      should "parse literal strings with normal characters" do
        result = parse "{foo bar baz}"
        result.should have(1).args
        result.args[0].should eval_to("foo bar baz")
      end
      
      should "parse literal strings with strange characters" do
        result = parse "{[føo {bar] bäz!}"
        result.should have(1).args
        result.args[0].should eval_to("[føo {bar] bäz!")
      end
      
      should "parse interpolated strings with no interpolated methods" do
        result = parse '"foo bar baz"'
        result.should have(1).args
        result.args[0].should eval_to("foo bar baz")
      end
      
      should "parse interpolated strings with interpolated methods" do
        result = parse '"foo [bar baz]"'
        result.should have(1).args
        result.args[0].should eval_to("foo baz")
        
        result = parse '"foo [bar [baz hat]]"'
        result.should have(1).args
        result.args[0].should eval_to("foo hat")
      end
      
      should "parse methods" do
        result = parse "[foo bar]"
        result.should have(1).args
        result.args[0].should eval_to("bar")
        
        result = parse "[foo bar [baz {hat cat}]]"
        result.should have(1).args
        result.args[0].should eval_to("bar hat cat")
      end
      
      should "parse arrays" do
        result = parse "(foo bar)"
        result.should have(1).args
        result.args[0].should have(2).args
        result.args[0].should eval_to_instance_of(Array)
        result.args[0].should eval_to(["foo", "bar"])
        
        result = parse "foo (bar {cat in hat})"
        result.should have(2).args
        result.args[0].should eval_to("foo")
        result.args[1].should have(2).args
        result.args[1].should eval_to_instance_of(Array)
        result.args[1].should eval_to(["bar", "cat in hat"])
        
        result = parse '(foo "bar baz hat" [say cat] "cat [in hat]")'
        result.should have(1).args
        result.args[0].should have(4).args
        result.args[0].should eval_to(["foo", "bar baz hat", "cat", "cat hat"])
      end
      
      should "parse multiple arguments" do
        parse("foo").should have(1).args
        parse("foo bar").should have(2).args
        parse("foo {bar}").should have(2).args
        parse("foo [baz {hat}] cat").should have(3).args
        parse("[foo bar] {cat in the hat} fat").should have(3).args
        parse('fat "cat sat [in the] hat" {which was sitting on the} mat').should have(4).args
      end
    end # ArgumentsParser instance
  end
end
