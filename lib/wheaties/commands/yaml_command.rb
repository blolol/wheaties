class YamlCommand < Command
  def assign_value(value, message)
    message.reply("Sorry! You can only modify a YAML command on my website: #{url}", true)
  end

  def invoke(environment)
    RubyInvocationResult.new(parsed_body)
  end

  private

  def parsed_body
    YAML.safe_load(body)
  end
end
