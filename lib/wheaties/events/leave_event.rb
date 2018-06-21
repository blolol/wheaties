module Wheaties
  class LeaveEvent < BaseEvent
    private

    def event
      :leave
    end

    def legacy_grunt_event
      :on_part
    end
  end
end
