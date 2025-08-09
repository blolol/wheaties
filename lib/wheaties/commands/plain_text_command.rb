class PlainTextCommand < Command
  include Wheaties::CommandAssignable
  include Wheaties::PlainTextDocumentable

  def invoke(environment)
    Wheaties::PlainTextInvocationResult.new(body, environment.args)
  end
end
