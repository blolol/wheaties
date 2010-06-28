module Grunt
  module Extensions
    module Channel
      def dup
        @name = name.dup
        @users = users.dup
        super
      end
    end # Channel
  end # Extensions
end

module Wheaties
  class Channel
    include Grunt::Extensions::Channel
  end
end
