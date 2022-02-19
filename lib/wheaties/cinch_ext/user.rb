module Cinch
  class User
    def blolol
      @blolol ||= ::Wheaties::BlololUser.new(self)
    end
  end
end
