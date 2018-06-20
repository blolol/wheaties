module Wheaties
  module DocumentationHelpers
    private

    def desc(command)
      if command.desc
        "#{command.name}: #{command.desc}"
      end
    end

    def help(name)
      command = Command.find_by_name(name)
      [desc(command), usage(command), command.help].flatten.compact.join("\n")
    end

    def usage(command)
      if command.usage
        "Usage: #{command.usage}"
      end
    end
  end
end
