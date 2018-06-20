module Wheaties
  class LeaveEvent < BaseEvent
    private

    def commands
      Command.where(events: 'on_part')
    end

    def event
      :leave
    end
  end
end
