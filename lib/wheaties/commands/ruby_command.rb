class RubyCommand < Command
  def assign_value(value, message)
    message.reply("Sorry! You can only modify a Ruby command on my website: #{url}", true)
  end

  def invoke(environment)
    return_value = environment.eval(self)
    Wheaties::RubyInvocationResult.new(return_value)
  end
end
