module Grunt
  class Evaluator
    include Grunt::Concerns::Commands
    include Grunt::Concerns::Convenience
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :name, :locals
    
    EXPOSED_METHODS = [ :desc, :help, :usage, :get, :set, :increment, :inc,
      :send, :pm?, :command?, :event?, :decrement, :dec, :bold, :b, :italic,
      :i, :plain, :pl, :color, :co, :uncolor, :uc, :colors,
      *Wheaties::Concerns::Formatting::COLORS.keys ]
    
    def initialize(name, args = nil, locals = {})
      @name = name
      @args = args.dup unless args.nil?
      @locals = locals.dup
    end
    
    def eval!
      if locals[:level].nil?
        locals[:level] = 0
      else
        locals[:level] += 1
      end
      
      locals[:args] = if @args.is_a?(String) && !@args.empty?
                        parser = ArgumentsParser.new.parse(@args)
                        raise ArgumentParseError, name unless parser
                        parser.eval!(locals)
                      elsif @args.is_a?(Array)
                        @args
                      else
                        []
                      end
      locals[:args].compact!
      
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
        new_locals = locals.merge(:caller => name)
        Evaluator.new(method_name.to_s, args, new_locals).eval!
      end
    end
    
    protected
      def eval_command(command)
        command.used!(sender.nick) if primary? && !event?
        eval_method = "eval_#{command.class.name.underscore}"
        respond_to?(eval_method) ? send(eval_method, command) : nil
      end
      
      def eval_plain_text_command(command)
        result = ERB.new(command.body, nil, "%").result(binding)
        result.gsub(/[\r\n]{2}/, "\n \n") # Preserve blank lines with dummy spaces
      end
      
      def eval_random_line_command(command)
        result = ERB.new(command.body, nil, "%").result(binding)
        result.split(/[\r\n]{2}/).map do |lines|
          lines.split(/[\r\n]/).random
        end.join("\n")
      end
      
      def eval_ruby_command(command)
        eval(command.body)
      end
      
      def eval_yaml_command(command)
        result = ERB.new(command.body, nil, "%").result(binding)
        YAML.load(result)
      rescue
        nil
      end
  end
end
