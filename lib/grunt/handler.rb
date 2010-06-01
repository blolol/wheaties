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
            :stack_level => 0
          }
          
          timeout = (Grunt.config["timeout"] || 10).to_i
          SystemTimer.timeout_after(timeout) do
            result = Evaluator.new(command[:name], command[:args], locals).eval!
            privmsg(result, response.channel) if result
          end
        rescue NoCommandError => e
          notice("#{e.name} is not a command!", response.sender.nick)
        rescue ArgumentParseError => e
          notice("You made a mistake somewhere in your arguments for #{command[:name]}!", response.sender.nick)
        rescue Timeout::Error => e
          notice("#{command[:name]} timed out after #{timeout} seconds!", response.sender.nick)
        rescue => e
          notice("Error in #{command[:name]}: #{e.message}", response.sender.nick)
          log(:debug, e.message)
          log(:debug, e.backtrace.join("\n"))
        end
      end
  end
end
