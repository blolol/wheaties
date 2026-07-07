module Wheaties
  class ResponseCollector
    FORMATS = %i(all discord plain ruby)

    def initialize
      @responses = {}
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

    def ruby(&block)
      @responses[:ruby] = block
    end
  end
end
