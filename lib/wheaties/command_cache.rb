module Wheaties
  class CommandCache
    def initialize
      @cache = {}
    end

    def get(name)
      @cache.fetch(name) do
        @cache[name] = Command.find_by(name: name)
      end
    end
  end
end
