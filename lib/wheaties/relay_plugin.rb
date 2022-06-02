module Wheaties
  class RelayPlugin
    include Cinch::Plugin

    # Constants
    MESSAGE_CHECK_INTERVAL = Integer(ENV.fetch('RELAY_MESSAGE_CHECK_INTERVAL_SECONDS', 10))
    QUEUE_URL = ENV['RELAY_QUEUE_URL']

    def self.enabled?
      QUEUE_URL.present?
    end

    # Timers
    if enabled?
      timer MESSAGE_CHECK_INTERVAL, method: :deliver_queued_messages
    end

    private

    def batch_delete_entry(message)
      { id: message.message_id, receipt_handle: message.receipt_handle }
    end

    def delete_delivered_messages(messages)
      messages.each_slice(10) do |messages|
        batch_of_entries = messages.map { |message| batch_delete_entry(message) }
        sqs.delete_message_batch(entries: batch_of_entries, queue_url: QUEUE_URL)
      end
    end

    def deliver_queued_messages
      messages = queued_messages

      messages.each do |message|
        RelayEvent.new(bot, message.body).deliver
      end

      delete_delivered_messages(messages)
    end

    def queued_messages
      sqs.receive_message(max_number_of_messages: 10, queue_url: QUEUE_URL,
        wait_time_seconds: MESSAGE_CHECK_INTERVAL - 1).messages
    end

    def sqs
      @sqs ||= Aws::SQS::Client.new
    end
  end
end
