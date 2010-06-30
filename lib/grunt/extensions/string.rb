module Grunt
  module Extensions
    module String
      def to_num
        index(".") ? to_f : to_i
      end
    end # String
  end # Extensions
end

class String
  include Grunt::Extensions::String
end
