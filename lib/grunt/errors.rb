module Grunt
  class Error < ::StandardError; end
  
  class CommandError < Error
    attr_reader :command, :attributes
    
    def initialize(command, attributes = {})
      @command, @attributes = command, attributes
    end
    
    def method_missing(method_name, *args)
      attributes[method_name] if attributes.key?(method_name)
    end
  end
  
  class ArgumentParseError < CommandError; end
  class NoCommandError     < CommandError; end
  class StackDepthError    < CommandError; end
end
