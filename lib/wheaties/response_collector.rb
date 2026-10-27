module Wheaties
  class ResponseCollector
    FORMATS = %i(all discord plain ruby)

    def initialize
      @responses = {}
      @responded = false
    end

    def all(&block)
      @responses[:all] = block
    end

    def any(**formats, &block)
      formats = formats.presence || [:all]
      formats.each do |format|
        public_send(format, &block)
      end
    end

    def discord(&block)
      @responses[:discord] = block
    end

    def plain(&block)
      @responses[:plain] = block
    end

    def respond!(message, *formats)
      return if responded?
      result = response(*formats)&.call
      RubyInvocationResult.new(result).reply_to_chat(message)
      @responded = true
      self
    end

    def responded?
      @responded
    end

    def response(*formats)
      @responses.values_at(*formats.uniq).compact.first || @responses[:all]
    end

    def ruby(&block)
      @responses[:ruby] = block
    end
  end
end
