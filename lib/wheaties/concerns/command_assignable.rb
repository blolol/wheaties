module Wheaties
  module CommandAssignable
    def assign_value(value, message)
      self.body << "\n#{value}"
      self.body.strip!

      if save
        message.reply("Okay, “#{name}” is now #{value}", true)
      else
        message.reply("Sorry, I couldn't update “#{name}”: #{errors.full_messages.join(', ')}", true)
      end
    end
  end
end
