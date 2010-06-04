module Grunt
  module Responses
    module Messages
      def on_privmsg
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
