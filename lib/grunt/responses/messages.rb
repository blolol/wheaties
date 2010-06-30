module Grunt
  module Responses
    module Messages
      def on_privmsg
        Grunt.history << response
        
        if (metadata = parse_command(response.text)) ||
           (response.pm? && metadata = parse_pm_command(response.text))
          handle_command(metadata[:name], metadata[:args])
        elsif metadata = parse_assignment(response.text)
          handle_assignment(metadata[:name], metadata[:text])
        end
      end
    end # Messages
  end # Responses
end
