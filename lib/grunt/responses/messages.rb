module Grunt
  module Responses
    module Messages
      def on_privmsg
        if (command = is_command?(response.text)) ||
           (response.pm? && command = is_pm_command?(response.text))
          handle_command(command)
        end
      end
    end
  end
end
