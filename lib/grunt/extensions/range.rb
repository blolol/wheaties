module Grunt
  module Extensions
    module Range
      # Choose one or more random elements from the range, optionally based on
      # weights, as in Grunt::Extensions::Array#random.
      def random(*args)
        to_a.random(*args)
      end
    end # Range
  end # Extensions
end

class Range
  include Grunt::Extensions::Range
end
