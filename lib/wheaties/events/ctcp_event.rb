module Wheaties
  class CtcpEvent < BaseEvent
    private

    def event
      :ctcp
    end

    def legacy_grunt_event
      :on_ctcp
    end
  end
end
