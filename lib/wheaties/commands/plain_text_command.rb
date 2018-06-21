class PlainTextCommand < Command
  include Wheaties::CommandAssignable

  def invoke(environment)
    PlainTextInvocationResult.new(body)
  end

  class PlainTextInvocationResult
    def initialize(text)
      @text = text
    end

    def reply_to_chat(message)
      message.safe_reply(@text)
    end

    def ruby_value
      @text
    end
  end
end
