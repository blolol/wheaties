module Wheaties
  module CommandAssignable
    def assign_value(value, message)
      self.body = "#{body}\n#{value}".strip
      self.updated_by = message.user.blolol&.username ||
        message.user.blolol&.authname_or_relayed_nick || message.user.nick
      updated_in = message.channel? ? message.channel.name : 'a private message'
      self.commit_message = "Updated by #{updated_by} in #{updated_in}"

      if save
        message.reply("Okay, “#{name}” is now #{value}", true)
      else
        message.reply("Sorry, I couldn't update “#{name}”: #{errors.full_messages.join(', ')}", true)
      end
    end
  end
end
