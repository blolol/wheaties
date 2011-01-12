module Grunt
  module Responses
    module Messages
      include Concerns::Matching
      
      def on_privmsg
        Grunt.history << response
        
        if response.text =~ command_regex
          handle_command $~[1], $~[2]
        elsif response.text =~ assignment_regex
          handle_assignment $~[1], $~[2]
        end
      end
    end
  end
end
