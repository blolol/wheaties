module Wheaties
  class NickEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_nick')
    end

    def event
      :nick
    end
  end
end
