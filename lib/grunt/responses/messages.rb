module Grunt
  module Responses
    module Messages
      def on_privmsg
        unless response.pm?
          history = (Grunt.history[response.channel] ||= [])
          history.pop if history.size >= (Grunt.config["history"] || 25).to_i
          history.unshift(response.dup)
        end
        
        if (command = is_command?(response.text)) ||
           (response.pm? && command = is_pm_command?(response.text))
          handle_command(command)
        elsif command = is_assignment?(response.text)
          handle_assignment(command)
        end
      end
      
      protected
        def is_assignment?(message)
          if message =~ /^\s*#{Wheaties::Connection.nick}\s*:\s*(.*?)\s+is\s+(.*)$/i
            { :name => $~[1], :text => $~[2] }
          end
        end
    end
  end
end
