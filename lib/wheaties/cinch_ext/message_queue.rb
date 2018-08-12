module Cinch
  class MessageQueue
    private

    # Replace the default implementation of MessageQueue#wait, which rate limits itself according to
    # the `messages_per_second` and `server_queue_size` bot settings. This implementation foregoes
    # any rate limiting to fix an issue where sleeping the current thread affects outgoing message
    # queueing. This is okay, because Wheaties only connects to a private server where message spam
    # is acceptable.
    def wait
      @log.clear
    end
  end
end
