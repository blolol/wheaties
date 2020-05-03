module Wheaties
  module CommandAssignable
    def assign_value(value, message)
      append_to_body(value)

      if save
        message.reply("Okay, “#{name}” is now #{value}", true)
      else
        message.reply("Sorry, I couldn't update “#{name}”: #{errors.full_messages.join(', ')}", true)
      end
    end

    private

    def append_to_body(value_to_append)
      self.body = "#{body}\n#{value_to_append}".strip
    end
  end
end
