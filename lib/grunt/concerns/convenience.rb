module Grunt
  module Concerns
    module Convenience
      protected
        def pm?
          response.pm? if response.respond_to?(:pm?)
        end
        
        def command?
          pm? ? parse_pm_command(response.text) : parse_command(response.text)
        end

        def event?
          locals[:is_event]
        end
        
        def subcommands!(&block)
          if args[0] =~ /^[a-zA-Z0-9_-]+$/
            subcommand = args.shift.strip.downcase
            begin
              Evaluator.new("#{name}_#{subcommand}", args, locals).eval!
            rescue Grunt::NoCommandError
              block.call if block_given?
            end
          else
            block.call if block_given?
          end
        end
        
        def get(name, default)
          command = YamlCommand.first(:name => name)
          command ? command.eval! : default
        end
        
        def set(name, value)
          command = YamlCommand.find_or_new(:name => name)
          command.body = YAML.dump(value)
          command.save!
        end
        
        def increment(name, by = 1)
          command = YamlCommand.first_or_new(:name => name)
          if (value = command.eval!).is_a?(Numeric)
            value += by
            command.body = YAML.dump(value)
            command.save!
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
