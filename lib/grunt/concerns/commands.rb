module Grunt
  module Concerns
    module Commands
      def parse_command(message, prefix = nil)
        prefix ||= Grunt.config["prefix"] || "."
        if message =~ /^#{Regexp.escape(prefix)}([a-zA-Z0-9_@\^\/\-\?\!]+)(?: +(.*))?$/
          { :name => $~[1], :args => $~[2] }
        else
          nil
        end
      end
      
      def parse_pm_command(message)
        parse_command(message, "")
      end
      
      def parse_assignment(message)
        if message =~ /^\s*#{Wheaties::Connection.nick}\s*[:,]*\s*(.*?)\s+is\s+(.*)$/i
          { :name => $~[1], :text => $~[2] }
        end
      end
    end
  end
end
