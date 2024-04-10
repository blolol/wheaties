module Wheaties
  class InvocationArguments < ::Array
    attr_reader :unparsed

    def initialize(parsed_arguments = [], unparsed_arguments = '')
      @unparsed = unparsed_arguments
      super(parsed_arguments)
    end
  end
end
