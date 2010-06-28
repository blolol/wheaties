module Grunt
  module Responses
    module Channel
      def on_join
        if response.sender.nick == connection.nick
          channel, history = response.channel, Grunt.history
          history[channel] = []
        end
      end
      
      def on_part
        if response.sender.nick == connection.nick
          channel, history = response.channel, Grunt.history
          history.delete(channel)
        end
      end
    end # Channel
  end # Responses
end
