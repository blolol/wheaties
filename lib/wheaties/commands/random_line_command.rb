class RandomLineCommand < Command
  include Wheaties::CommandAssignable
  include Wheaties::PlainTextDocumentable

  def invoke(environment)
    default_options = { count: 1, sort: 'random' }
    Wheaties::PlainTextInvocationResult.new(body, environment.args, default_options)
  end
end
