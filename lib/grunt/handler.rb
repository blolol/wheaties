module Grunt
  class Handler < Wheaties::Handler
    include Grunt::Responses::Messages
    
    protected
      def handle_command
        parser = CommandParser.new.parse(response.text)
        return unless parser
        
        begin
          locals = {
            :sender => response.sender.dup,
            :channel => response.channel,
            :args_string => response.text[/^.+?\s+(.*)$/, 1]
          }
          
          timeout = (Grunt.config["timeout"] || 10).to_i
          SystemTimer.timeout_after(timeout) do
            result = parser.eval(locals)
            privmsg(result, response.channel) if result
          end
        rescue NoCommandError => e
          notice("\"#{e.name}\" is not a command!", response.sender.nick)
        rescue Timeout::Error => e
          notice("\"#{parser.name}\" timed out after #{timeout} seconds!", response.sender.nick)
        end
      end
  end
end
