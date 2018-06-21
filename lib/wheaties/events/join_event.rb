module Wheaties
  class JoinEvent < BaseEvent
    private

    def event
      :join
    end

    def legacy_grunt_event
      :on_join
    end
  end
end
