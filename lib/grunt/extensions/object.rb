module Grunt
  module Extensions
    module Object
      def to_num
        unless !respond_to?(:to_s)
          case value = self.to_s
          when /^-?[\d_]+$/ then value.to_i
          when /^-?[\d\._eE]+$/ then value.to_f
          else value; end
        end
      end
    end # Object
  end # Extensions
end

class Object
  include Grunt::Extensions::Object
end
