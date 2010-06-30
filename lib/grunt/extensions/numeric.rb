module Grunt
  module Extensions
    module Numeric
      def to_num
        self
      end
    end # Numeric
  end # Extensions
end

class Numeric
  include Grunt::Extensions::Numeric
end
