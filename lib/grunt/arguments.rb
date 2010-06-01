module Arguments
  class Arguments < Treetop::Runtime::SyntaxNode
    def args
      elements
    end
    
    def eval!(locals = {})
      args.map do |arg|
        arg.eval!(locals)
      end
    end
  end
  
  class Argument < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      content.eval!(locals)
    end
  end
  
  class Method < Treetop::Runtime::SyntaxNode
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
  
  class InterpolatedString < Treetop::Runtime::SyntaxNode
    def arguments
      string_arguments.elements
    end
    
    def eval!(locals = {})
      arguments.map do |argument|
        argument.eval!(locals)
      end.join("")
    end
  end
  
  class InterpolatedText < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      text_value
    end
  end
  
  class LiteralString < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      content.text_value
    end
  end
  
  class WordString < Treetop::Runtime::SyntaxNode
    def eval!(locals = {})
      text_value
    end
  end
end
