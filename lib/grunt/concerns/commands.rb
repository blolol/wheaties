module Grunt
  module Concerns
    module Commands
      def is_command?(string)
        prefix = Grunt.config["prefix"] || "."
        string[/^#{Regexp.escape(prefix)}([a-zA-Z0-9_]+.*)$/, 1]
      end
    end
  end
end
