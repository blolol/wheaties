module Grunt
  class Handler < Wheaties::Handler
    include Grunt::Concerns::Commands
    include Grunt::Responses::Messages
    
    protected
      def handle_command(command)
        return unless command.is_a?(Hash)
        
        begin
          locals = {
            :sender => response.sender.dup,
            :channel => response.channel,
            :stack_depth => 1
          }
          
          timeout = (Grunt.config["timeout"] || 10).to_i
          GruntTimeout.timeout(timeout) do
            result = Evaluator.new(command[:name], command[:args], locals).eval!
            privmsg(result, response.channel) if result
          end
        rescue NoCommandError => e
          notice(%{"#{e.command}" is not a command!}, response.sender.nick)
        rescue ArgumentParseError => e
          notice(%{You made a mistake somewhere in your arguments for "#{e.command}"!}, response.sender.nick)
        rescue StackDepthError => e
          notice(%{"#{e.command}" called too many methods!}, response.sender.nick)
        rescue Timeout::Error
          notice(%{"#{command[:name]}" timed out after #{timeout} seconds!}, response.sender.nick)
        rescue => e
          notice(%{Error in "#{command[:name]}": #{e.message}}, response.sender.nick)
          log(:debug, e.message)
          log(:debug, e.backtrace.join("\n"))
        end
      end
  end
end
