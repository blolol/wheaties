module Grunt
  class Evaluator
    class << self
      def expose(*methods)
        @exposed_methods ||= []
        @exposed_methods += methods
      end
      
      def exposed?(method_name)
        @exposed_methods ||= []
        @exposed_methods.include?(method_name.to_sym)
      end
    end
    
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    expose :color, :c, :uncolor, :uc, :colors, :plain, :pl, :bold, :b,
           :italic, :i, :reverse, :underline, :u, *Wheaties::Concerns::Formatting::COLORS.keys
    
    def initialize(name, args = nil, locals = {})
      @name = name
      @args = args
      @locals = locals
    end
    
    def eval!
      locals[:stack_level] += 1
      raise "too much recursion" if locals[:stack_level] >= 10
      
      locals[:args] = if @args.is_a?(String) && !@args.empty?
                        parser = ArgumentsParser.new.parse(@args)
                        raise ArgumentParseError unless parser
                        parser.eval!(locals)
                      elsif @args.is_a?(Array)
                        @args
                      else
                        []
                      end
      
      if @args.is_a?(String)
        locals[:args].instance_eval do
          def args_string=(args_string)
            @args_string = args_string
          end
        
          def to_s
            @args_string
          end
        end
        locals[:args].args_string = @args
      end
      
      if Evaluator.exposed?(name) && respond_to?(name)
        send(name, *locals[:args])
      elsif command = Models::Command.first(:name => /^#{name}$/i)
        eval_method = "eval_#{command.type}"
        respond_to?(eval_method) ? send(eval_method, command) : nil
      else
        raise NoCommandError, name
      end
    end
    
    def method_missing(method_name, *args)
      if method_name == :locals
        locals
      elsif locals.key?(method_name)
        locals[method_name]
      else
        Evaluator.new(method_name.to_s, args, locals).eval!
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
