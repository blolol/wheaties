class YamlCommand < Command
  def invoke(environment)
    YamlInvocationResult.new(parsed_body)
  end

  private

  def parsed_body
    YAML.safe_load(body)
  end

  class YamlInvocationResult
    def initialize(yaml_object)
      @yaml_object = yaml_object
    end

    def reply_to_chat(message)
      message.safe_reply(@yaml_object.inspect)
    end

    def ruby_value
      @yaml_object
    end
  end
end
