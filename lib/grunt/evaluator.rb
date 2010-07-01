module Grunt
  class Evaluator
    include Grunt::Concerns::Commands
    include Grunt::Concerns::Convenience
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    EXPOSED_METHODS = [ :desc, :help, :usage, :get, :set, :increment, :inc, :send,
      :decrement, :dec, :bold, :b, :italic, :i, :plain, :pl, :color, :c,
      :uncolor, :uc, :colors, *Wheaties::Concerns::Formatting::COLORS.keys ]
    
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
      elsif command = Command.first(:name => /^#{Regexp.escape(name)}$/i)
        eval_command(command)
      elsif command = Command.first_by_regex(name)
        locals[:match] = command.match.dup
        eval_command(command)
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
      def eval_command(command)
        command.used!(sender.nick) unless event?
        eval_method = "eval_#{command.class.name.underscore}"
        respond_to?(eval_method) ? send(eval_method, command) : nil
      end
      
      def eval_plain_text_command(command)
        command.body.gsub("\n\n", "\n \n") # Preserve blank lines with dummy spaces
      end
      
      def eval_random_line_command(command)
        command.body.split(/[\r\n]{2}/).map do |lines|
          lines.split(/[\r\n]/).random
        end.join("\n")
      end
      
      def eval_ruby_command(command)
        Kernel.eval(command.body)
      end
      
      def eval_yaml_command(command)
        begin
          YAML.load(command.body)
        rescue; nil; end
      end
  end
end
