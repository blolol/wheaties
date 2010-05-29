module Command
  class Evaluable < Treetop::Runtime::SyntaxNode
    def name
      command_name.text_value
    end
    
    def arguments
      command_arguments.elements.map do |argument|
        argument.eval
      end
    end
    
    def eval(locals = {})
      locals[:args] = arguments
      
      # Add magic to enable commands to call args.to_s to get at the original,
      # unparsed argument string.
      if locals[:args_string]
        locals[:args].instance_eval do
          def args_string=(args_string)
            @args_string = args_string
          end
          
          def to_s
            @args_string
          end
        end
        locals[:args].args_string = locals[:args_string]
      end
      
      Grunt::Evaluator.new(name, locals).eval!
    end
  end
  
  class InterpolatedString < Treetop::Runtime::SyntaxNode
    def arguments
      string_arguments.elements
    end
    
    def eval
      arguments.map do |argument|
        argument.eval
      end.join("")
    end
  end
end
