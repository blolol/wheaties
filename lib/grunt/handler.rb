module Grunt
  class Handler < Wheaties::Handler
    include Grunt::Concerns::Commands
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
      def handle_command(command)
        return unless command.is_a?(Hash)
        
        begin
          locals = {
            :event => response.method_name,
            :response => response.dup,
            :sender => response.sender.dup,
            :from => response.from,
            :channel => response.channel.dup.tap { |c| c.users.sender = response.sender.dup }
          }.merge(command[:locals] || {})
          
          timeout = (Grunt.config["timeout"] || 10).to_i
          GruntTimeout.timeout(timeout) do
            result = Evaluator.new(command[:name], command[:args], locals).eval!
            privmsg(result, response.from) if result
          end
        rescue NoCommandError
        rescue ArgumentParseError => e
          notice(%{You made a mistake somewhere in your arguments for "#{e.command}"!}, response.sender.nick)
        rescue Timeout::Error
          notice(%{"#{command[:name]}" timed out after #{timeout} seconds!}, response.sender.nick)
        rescue => e
          notice(%{Error in "#{command[:name]}": #{e.message}}, response.sender.nick)
          log(:debug, e.message)
          log(:debug, e.backtrace.join("\n"))
        end
      end
      
      def handle_event(event)
        locals = { :is_event => true }
        command_hash = { :args => "", :locals => locals }
        
        Models::Command.all(:events => event).each do |command|
          command_hash[:name] = command.name
          handle_command(command_hash)
        end
      end
      
      def handle_assignment(assignment)
        return unless assignment.is_a?(Hash)
        
        command = Models::Command.first_or_new(:name => /^#{assignment[:name]}$/i)
        
        if command.new?
          command.name = assignment[:name]
          command.type = "plain_text"
          command.body = ""
          command.created_by = response.sender.nick
        else
          if %w(plain_text plain_text_random).include?(command.type)
            command.updated_by = response.sender.nick
          else
            notice(%{"#{command.name}" is a #{command.type.capitalize} command and may not be modified.}, response.sender.nick)
            return
          end
        end
        
        command.body << "#{command.body.empty? ? "" : "\n"}#{normalize(assignment[:text])}"
        
        begin
          command.save!
          notice(%{Saved "#{command.name}"!}, response.sender.nick)
        rescue MongoMapper::DocumentNotValid
          command.errors.each do |field, error|
            notice("Command #{field} #{error}!", response.sender.nick)
          end
        end
      end
      
      def normalize(body)
        body.gsub(/^\s*(\\)?(<.*?>)/i) do |match|
          $~[1].nil? ? "" : match
        end.gsub('\n', "\n")
      end
  end
end
