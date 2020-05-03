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
      each_line do |line|
        message.safe_reply(line)
      end
    end

    def ruby_value
      @text
    end

    private

    def each_line(&block)
      @text.each_line(&block)
    end
  end
end
