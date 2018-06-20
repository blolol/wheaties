module Wheaties
  class NullInvocationResult
    def reply_to_chat(message)
      # no-op
    end

    def ruby_value
      nil
    end
  end
end
