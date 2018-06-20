class RubyCommand < Command
  def invoke(environment)
    return_value = environment.eval(self)
    Wheaties::RubyInvocationResult.new(return_value)
  end
end
