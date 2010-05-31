module Grunt
  class Evaluator
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    def initialize(name, locals)
      @name = name
      @locals = locals
    end
    
    def eval!
      command = Models::Command.first(:name => /^#{name}$/i)
      raise NoCommandError, name unless command
      
      eval_method = "eval_#{command.type}"
      respond_to?(eval_method) ? send(eval_method, command) : nil
    end
    
    def method_missing(method_name, *args)
      if method_name == :locals
        locals
      elsif locals.key?(method_name)
        locals[method_name]
      else
        Evaluator.new(method_name.to_s, locals).eval!
      end
    end
    
    protected
      def eval_ruby(command)
        eval(command.body)
      end
      
      # Remove comments (except for escaped comments), and add a dummy space
      # to completely blank lines in order to preserve them.
      def eval_text(command)
        command.body.gsub(/^\s*(\\\s*)?(#.*)$/) do |match|
          $1.nil? ? "\0" : match[/^\\\s*(.*)$/, 1]
        end.gsub(/(\n)?\000\n/) do |match|
          $1.nil? ? "" : "\n"
        end.gsub("\n\n", "\n \n")
      end
  end
end
