module Grunt
  module Concerns
    module Commands
      def is_command?(string, prefix = nil)
        prefix ||= Grunt.config["prefix"] || "."
        if string =~ /^#{Regexp.escape(prefix)}([a-zA-Z0-9_\-\?\!]+)(?: +(.*))?$/
          { :name => $~[1], :args => $~[2] }
        else
          nil
        end
      end
      
      def is_pm_command?(string)
        is_command?(string, "")
      end
    end
  end
end
