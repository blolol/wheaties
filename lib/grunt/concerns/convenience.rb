module Grunt
  module Concerns
    module Convenience
      protected
        def pm?
          response.pm? if response.respond_to?(:pm?)
        end
        
        # Was the message which invoked this command evaluation an actual
        # command? This is often useful to know during events.
        def command?
          pm? ? parse_pm_command(response.text) : parse_command(response.text)
        end
        
        # Is the command currently being evaluated the "primary" command (that
        # is, is it the first command being evaluated for a given invocation)?
        def primary?
          locals[:level] == 0
        end
        
        # Is this command being evaluated automatically in response to an event?
        def event?
          locals[:is_event] == true
        end
        
        def subcommands!(&block)
          if args[0] =~ /^[a-zA-Z0-9_-]+$/
            subcommand = args.shift.strip.downcase
            args.compact!
            begin
              Evaluator.new("#{name}_#{subcommand}", args, locals).eval!
            rescue Grunt::NoCommandError
              block.call(subcommand) if block_given?
            end
          else
            block.call(subcommand) if block_given?
          end
        end
        
        def get(name, default = nil)
          command = YamlCommand.first(:name => name)
          command ? eval_yaml_command(command) : default
        end
        
        def set(name, value)
          command = YamlCommand.first_or_new(:name => name)
          command.body = YAML.dump(value)
          if command.new?
            command.name = name
            command.created_by = sender.nick
          end
          command.save! ? value : false
        end
        
        def increment(name, by = 1)
          command = YamlCommand.first_or_new(:name => name)
          if (value = eval_yaml_command(command) || 0).is_a?(Numeric)
            value += by
            command.body = YAML.dump(value)
            if command.new?
              command.name = name
              command.created_by = sender.nick
            end
            command.save! ? value : false
          else
            raise ArgumentError, "can't increment a #{value.class.name}!"
          end
        end
        alias :inc :increment
        
        def decrement(name, by = 1)
          begin
            increment(name, by * -1)
          rescue ArgumentError => e
            e.message.gsub!("increment", "decrement")
            raise e
          end
        end
        alias :dec :decrement
        
        def usage(name, silent = false)
          if command = Command.first(:name => /^#{name}$/i) ||
             command = Command.first_by_regex(name)
            if command.usage
              "Usage: #{command.usage}"
            else
              notice %{There is no usage information for "#{name}".}, sender.nick unless silent
            end
          else
            notice %{"#{name}" is not a command!}, sender.nick unless silent
          end
        end
        
        def desc(name, silent = false)
          if command = Command.first(:name => /^#{name}$/i) ||
             command = Command.first_by_regex(name)
            if command.desc
              "#{b}#{command.name}:#{pl} #{command.desc}"
            else
              notice %{There is no description for "#{name}".}, sender.nick unless silent
            end
          else
            notice %{"#{name}" is not a command!}, sender.nick unless silent
          end
        end
        
        def help(name)
          if command = Command.first(:name => /^#{name}$/i) ||
             command = Command.first_by_regex(name)
            unless command.help.empty? && !command.usage && !command.desc
              command.help.unshift(desc(name, true), usage(name, true))
            else
              notice %{There is no help information for "#{name}".}, sender.nick
            end
          else
            notice %{"#{name}" is not a command!}, sender.nick
          end
        end
    end # Convenience
  end # Concerns
end
