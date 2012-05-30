module Grunt
  module Concerns
    module Matching
      def formatting_regex
        @formatting_regex ||=
          /(?:#{Wheaties::Concerns::Formatting::ANY_FORMATTING}|\s)*/
      end
      
      def assignment_regex
        nick = Wheaties::Connection.nick
        /\A#{formatting_regex}#{nick}\s*:+\s*(.*?)\s+is\s+(.*)\Z/i
      end
      
      def command_regex
        return @command_regex if @command_regex
        prefix = Regexp.escape(Grunt.config["prefix"] || ".")
        format = formatting_regex
        @command_regex = /\A#{format}#{prefix}(\S+)\s*(.*)\Z/
      end
    end
  end
end
