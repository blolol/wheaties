module Wheaties
  class UserDecorator < SimpleDelegator
    ERGO_USER_PREFIX = '~'

    def user
      @user ||= __getobj__.user.delete_prefix(ERGO_USER_PREFIX)
    end
  end
end
