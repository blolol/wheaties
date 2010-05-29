module Grunt
  class Evaluator
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    def initialize(name, locals)
      @name = name
      @locals = locals
    end
    
    def eval!
      command = Models::Command.first(:name => /^#{name}$/i)
      raise NoCommandError, name unless command
      
      eval(command.body)
    end
    
    def method_missing(method_name, *args)
      if locals.key?(method_name)
        locals[method_name]
      else
        Evaluator.new(method_name.to_s, locals).eval!
      end
    end
    
    protected
      def log(level, *args)
        Wheaties::Connection.instance.log(level, *args)
      end
  end
end
