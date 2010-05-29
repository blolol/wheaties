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
          
          result = parser.eval(locals)
          privmsg(result, response.channel) if result
        rescue NoCommandError => e
          privmsg("\"#{e.name}\" is not a command!", response.channel)
        end
      end
  end
end
