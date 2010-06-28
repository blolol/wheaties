module Grunt
  class Evaluator
    include Grunt::Concerns::Commands
    include Grunt::Concerns::Convenience
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    EXPOSED_METHODS = [ :desc, :help, :usage, :bold, :b, :italic, :i, :plain, :pl,
      :color, :c, :uncolor, :uc, :colors, *Wheaties::Concerns::Formatting::COLORS.keys ]
    
    def initialize(name, args = nil, locals = {})
      @name = name
      @args = args.dup unless args.nil?
      @locals = locals.dup
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
      elsif command = Models::Command.first(:name => /^#{Regexp.escape(name)}$/i, :name_is_regex => false)
        command.used!(sender.nick) unless event?
        eval_method = "eval_#{command.type}"
        respond_to?(eval_method) ? send(eval_method, command) : nil
      elsif result = Models::Command.find_by_regex(name)
        locals[:match] = result[:match].dup
        command = result[:command]
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
      
      # Add a dummy space to blank lines in order to preserve them.
      def eval_plain_text(command)
        command.body.gsub("\n\n", "\n \n")
      end
      
      # Apply plain text formatting, then pick a random line.
      def eval_plain_text_random(command)
        command.body.split(/[\r\n]{2}/).map do |lines|
          lines.split("\n").random
        end.join("\n")
      end
  end
end
