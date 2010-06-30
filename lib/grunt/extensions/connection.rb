module Wheaties
  class Connection
    alias :original_broadcast :broadcast

    def broadcast(command, *args)
      original_broadcast(command, *args)
      
      if command.to_s.upcase == "PRIVMSG"
        options = args.pop
        line = ":#{Wheaties::Connection.nick}!#{Wheaties::Connection.user}@wheaties "
        line << "PRIVMSG #{args.join(" ")} :#{options[:text]}"
        Grunt.history << Wheaties::Response.new(line)
      end
    end
  end # Connection
end
