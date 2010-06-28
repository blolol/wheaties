module Grunt
  module Concerns
    module Convenience
      protected
        def command?
          if response.pm?
            is_pm_command?(response.text)
          else
            is_command?(response.text)
          end
        end

        def pm?
          response.pm?
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
        
        def usage(name, silent = false)
          if command = Models::Command.first(:name => /^#{name}$/i) ||
             command = Models::Command.first_by_regex(name)
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
          if command = Models::Command.first(:name => /^#{name}$/i) ||
             command = Models::Command.first_by_regex(name)
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
          if command = Models::Command.first(:name => /^#{name}$/i) ||
             command = Models::Command.first_by_regex(name)
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
