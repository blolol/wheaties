module Grunt
  module Extensions
    module Set
      attr_accessor :sender
      
      # Scope Channel#users down to those who are neither the bot itself, nor
      # the sender of the message currently being handled.
      #
      #     <Mt_K3> hey guys, what's up?
      #     channel.users        => CCP, Doolan, Gafwyn, Mt_K3, Raws, Wheaties
      #     channel.users.others => CCP, Doolan, Gafwyn, Raws
      def others
        users = self.dup
        users.delete_if do |user|
          user.nick == Wheaties::Connection.nick ||
          user.nick == sender.nick
        end
        users
      end
    end # Set
  end # Extensions
end

class Set
  include Grunt::Extensions::Array
  include Grunt::Extensions::Set
end
