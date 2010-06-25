module Grunt
  class Evaluator
    include Grunt::Concerns::Commands
    include Grunt::Concerns::Convenience
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    EXPOSED_METHODS = [ :desc, :help, :usage ]
    
    def initialize(name, args = nil, locals = {})
      @name = name
      @args = args
      @locals = locals
    end
    
    def eval!
      locals[:args] = if @args.is_a?(String) && !@args.empty?
                        parser = ArgumentsParser.new.parse(@args)
                        raise ArgumentParseError, name unless parser
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
      
      if EXPOSED_METHODS.include?(name.to_sym) && respond_to?(name)
        send(name, *locals[:args])
      elsif command = Models::Command.first(:name => /^#{name}$/i)
        command.used!(sender.nick) unless event?
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
      
      # Add a dummy space to blank lines in order to preserve them, and hide
      # old-school "<reply>" and friends (unless they are escaped).
      def eval_plain_text(command)
        body = command.body.dup
        body.gsub!("\n\n", "\n \n")
        body.gsub(/^\s*(\\)?(<.*?>)/) do |match|
          $~[1].nil? ? "" : $~[2]
        end
      end
  end
end
