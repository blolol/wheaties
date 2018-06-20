module Wheaties
  class BuiltInCommand
    # Attributes
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def built_in?
      true
    end

    def id
      nil
    end

    def invoke(environment)
      environment.invoke_built_in_command(@name)
    end
  end
end
