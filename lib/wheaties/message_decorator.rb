module Wheaties
  class MessageDecorator < SimpleDelegator
    def user
      @user ||= UserDecorator.new(__getobj__.user)
    end
  end
end
