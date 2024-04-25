module Wheaties
  class EventCommandCache
    # Constants
    CACHE_TTL_SECONDS = ENV['EVENT_COMMAND_CACHE_TTL_SECONDS'] || 300

    def initialize(event)
      @event = event
    end

    def commands
      if cache_expired?
        refresh_cache
      end

      @commands
    end

    private

    def cache_expired?
      @commands.nil? || @last_updated_at.nil? ||
        (Time.now - @last_updated_at) >= CACHE_TTL_SECONDS
    end

    def refresh_cache
      @commands = Command.where(events: @event).to_a
      @last_updated_at = Time.now
    end
  end
end
