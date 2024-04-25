module Wheaties
  class TopicEvent < BaseEvent
    private

    def event
      :topic
    end

    def legacy_grunt_event
      :on_topic
    end
  end
end
