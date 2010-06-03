module Grunt
  module Responses
    module Messages
      def on_privmsg
        if (command = is_command?(response.text)) ||
           (response.pm? && command = is_pm_command?(response.text))
          handle_command(command)
        elsif command = is_assignment?(response.text)
          log(:debug, %{Dynamically assign text to "#{command[:name]}"})
        end
      end
      
      protected
        def is_assignment?(message)
          if message =~ /^\s*#{Wheaties::Connection.nick}\s*:\s*([a-zA-Z0-9_]+)\s+is\s+(.*)$/i
            { :name => $~[1], :text => $~[2] }
          end
        end
    end
  end
end
