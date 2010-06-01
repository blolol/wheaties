module Arguments
  class ArgumentsNode < Treetop::Runtime::SyntaxNode
    def args
      elements
    end
    
    def eval!(locals = {})
      args.map do |arg|
        arg.eval!(locals)
      end
    end
  end
  
  class ArgumentNode < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      content.eval!(locals)
    end
  end
  
  class MethodNode < Treetop::Runtime::SyntaxNode
    def name
      method_name.text_value
    end
    
    def args
      arguments.elements
    end
    
    def eval!(locals = {})
      args_string = arguments.text_value.strip
      Grunt::Evaluator.new(name, args_string, locals).eval!
    end
  end
  
  class InterpolatedStringNode < Treetop::Runtime::SyntaxNode
    def arguments
      string_arguments.elements
    end
    
    def eval!(locals = {})
      arguments.map do |argument|
        argument.eval!(locals)
      end.join("")
    end
  end
  
  class InterpolatedTextNode < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      text_value
    end
  end
  
  class LiteralStringNode < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      content.text_value
    end
  end
  
  class WordStringNode < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      text_value
    end
  end
end
