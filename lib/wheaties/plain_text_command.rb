class PlainTextCommand < Command
  def invoke(environment)
    PlainTextInvocationResult.new(body)
  end

  class PlainTextInvocationResult
    def initialize(text)
      @text = text
    end

    def reply_to_chat(message)
      @text.each_line do |line|
        message.safe_reply(line)
      end
    end

    def ruby_value
      @text
    end
  end
end
