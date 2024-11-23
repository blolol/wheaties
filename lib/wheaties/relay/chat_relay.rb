module Wheaties
  module Relay
    # Listens for incoming external messages from an Amazon SQS queue, and forwards the messages to
    # Discord and/or IRC.
    class ChatRelay
      RELAY_TO_IRC_REDIS_PUBSUB_CHANNEL = 'wheaties:relay:irc'

      def initialize(queue_url, wait_time_seconds: 10)
        @queue_url = queue_url
        @wait_time_seconds = wait_time_seconds
      end

      def start
        loop do
          deliver_queued_messages
        end
      end

      private

      def batch_delete_entry(message)
        { id: message.message_id, receipt_handle: message.receipt_handle }
      end

      def delete_delivered_messages(messages)
        messages.each_slice(10) do |messages|
          batch_of_entries = messages.map { |message| batch_delete_entry(message) }
          sqs.delete_message_batch(entries: batch_of_entries, queue_url: @queue_url)
        end
      end

      def deliver_queued_messages
        messages = queued_messages

        messages.each do |message|
          relay_event(message.body).forward
        end

        delete_delivered_messages(messages)
      end

      def logger
        Wheaties.logger
      end

      def queued_messages
        sqs.receive_message(max_number_of_messages: 10, queue_url: @queue_url,
          wait_time_seconds: @wait_time_seconds).messages
      end

      def relay_event(payload)
        json = JSON.parse(payload)
        logger.info("Handling chat relay event: #{json.inspect}")

        case json['version']
        when 1, '1', nil
          Relay::ChatEventV1.new(json)
        when 2, '2'
          Relay::ChatEventV2.new(json)
        else
          logger.warn("Invalid chat relay event schema version: #{payload.inspect}")
          Relay::NilEvent.new
        end
      rescue JSON::ParserError
        logger.warn("Malformed chat relay event: #{payload.inspect}")
        Relay::NilEvent.new
      end

      def sqs
        @sqs ||= Aws::SQS::Client.new
      end
    end
  end
end
