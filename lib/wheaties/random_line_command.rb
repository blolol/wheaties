class RandomLineCommand < Command
  def invoke(environment)
    RandomLineInvocationResult.new(random_line)
  end

  private

  def random_line
    body.lines.sample
  end

  class RandomLineInvocationResult
    def initialize(random_line)
      @random_line = random_line
    end

    def reply_to_chat(message)
      message.safe_reply(@random_line)
    end

    def ruby_value
      @random_line
    end
  end
end
