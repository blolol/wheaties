module Command
  class Evaluable < Treetop::Runtime::SyntaxNode
    def name
      command_name.text_value
    end
    
    def arguments
      command_arguments.elements
    end
    
    def eval
      arguments.map do |argument|
        argument.eval
      end.join(" ")
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
