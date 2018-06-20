module Wheaties
  class ExposedMethodInvoker
    def initialize(name)
      @name = name
    end

    def invoke(environment)
      environment.invoke_method_as_command(@name)
    end
  end
end
