module Wheaties
  class JoinEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_join')
    end

    def event
      :join
    end
  end
end
