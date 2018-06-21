module Wheaties
  class NickEvent < BaseEvent
    private

    def event
      :nick
    end

    def legacy_grunt_event
      :on_nick
    end
  end
end
