module Wheaties
  class MessageHistory
    def initialize(bot)
      @histories = Hash.new do |hash, target|
        hash[target] = TargetHistory.new
      end
    end

    def for(target)
      history_key = key(target)
      mutex_key = "#{history_key}_message_history"
      target.bot.synchronize(mutex_key) { @histories[key(target)] }
    end

    def push(message)
      self.for(message.target).push(message)
    end

    private

    def key(target)
      if target.is_a?(Cinch::Channel)
        target.name
      elsif target.is_a?(Cinch::User)
        target.user
      else
        target.to_s
      end
    end

    class TargetHistory
      # Delegates
      delegate :[], :clear, :dup, :each, :first, :last, :size, to: :@messages

      def initialize
        @messages = []
      end

      def push(message)
        @messages.unshift(message)
        trim_to_max_size
        message
      end

      private

      def max_size
        @max_size ||= Integer(ENV.fetch('MESSAGE_HISTORY_SIZE', 25))
      end

      def trim_to_max_size
        while @messages.size > max_size
          @messages.pop
        end
      end
    end
  end
end
