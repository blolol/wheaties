module Wheaties
  class BuiltInCommand
    # Attributes
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def assign_value(value, message)
      message.reply("Sorry, you can't modify a built-in command! 🙅‍♀️", true)
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
