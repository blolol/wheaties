module Grunt
  class Handler < Wheaties::Handler
    include Grunt::Concerns::Commands
    include Grunt::Responses::Channel
    include Grunt::Responses::Messages
    
    EXPOSED_EVENTS = [ :on_ctcp, :on_join, :on_nick, :on_part, :on_privmsg ]
    
    alias :original_handle :handle
    
    def handle
      original_handle
      
      if EXPOSED_EVENTS.include?(response.method_name)
        handle_event(response.method_name)
      end
    end
    
    protected
      def handle_command(name, args = [], locals = {})
        locals = {
          :response => response,
          :event => response.method_name,
          :sender => response.sender
        }.merge(locals)
        
        locals[:from] = response.from if response.respond_to?(:from)
        if response.respond_to?(:channel)
          locals[:history] = Grunt.history[response.channel] || []
          locals[:channel] = response.channel.dup.tap do |c|
            c.users.sender = response.sender.dup
          end unless response.pm?
        end
        
        begin
          timeout = (Grunt.config["timeout"] || 10).to_i
          GruntTimeout.timeout(timeout) do
            result = Evaluator.new(name, args, locals).eval!
            privmsg(result, response.from) if result
          end
        rescue NoCommandError => e
          notice(%{"#{e.command}" is not a command!}, response.sender.nick)
        rescue ArgumentParseError => e
          notice(%{You made a mistake somewhere in your arguments for "#{e.command}"!}, response.sender.nick)
        rescue Timeout::Error
          notice(%{"#{name}" timed out after #{timeout} seconds!}, response.sender.nick)
        rescue => e
          notice(%{#{e.class.name} in "#{name}": #{e.message}}, response.sender.nick)
          log(:error, e.message)
          log(:error, e.backtrace.join("\n"))
        end
      end
      
      def handle_event(event)
        locals = { :is_event => true }
        
        Command.all(:events => event, :fields => [:name]).each do |command|
          handle_command(command.name, "", locals)
        end
      end
      
      def handle_assignment(name, text)
        command = Command.first(:name => /^#{name}$/i)
        
        if command
          if [PlainTextCommand, RandomLineCommand].include?(command.class)
            command.updated_by = response.sender.nick
          else
            notice(%{"#{command.name}" is a #{command.class.humanize} command and may not be modified.}, response.sender.nick)
            return
          end
        else
          command = PlainTextCommand.new(:name => name, :created_by => response.sender.nick)
        end
        
        command.body << command.body.nil? || command.body.empty? ? "" : "\n"
        command.body << text.gsub('\n', "\n")
        
        begin
          command.save!
          notice(%{Saved "#{command.name}"!}, response.sender.nick)
        rescue MongoMapper::DocumentNotValid
          command.errors.each do |field, error|
            notice("Command #{field} #{error}!", response.sender.nick)
          end
        end
      end
  end
end
