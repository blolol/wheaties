module Grunt
  module Responses
    module Messages
      def on_privmsg
        handle_command
      end
    end
  end
end
