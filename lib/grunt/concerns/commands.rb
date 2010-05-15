module Grunt
  module Concerns
    module Commands
      def command?(line)
        prefix = Grunt.config.fetch("prefix", ".")
        line =~ /^#{Regexp.escape(prefix)}\S+/i
      end
    end
  end
end
