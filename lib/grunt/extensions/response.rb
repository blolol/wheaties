module Grunt
  module Extensions
    module Response
      def dup
        @sender = sender.dup
        super
      end
    end # Response
  end # Extensions
end

module Wheaties
  class Response
    include Grunt::Extensions::Response
  end
end
