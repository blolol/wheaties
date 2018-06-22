module Wheaties
  class CommandCache
    def initialize
      @cache = Hash.new do |cache, name|
        command = find_by_name(name) || find_by_regex(name)
        cache[name] = command if command
      end
    end

    def get(name)
      @cache[name]
    end

    private

    def find_by_name(name)
      Command.where(name: name).first
    end

    def find_by_regex(input)
      Command.find_by_regex(input)
    end
  end
end
