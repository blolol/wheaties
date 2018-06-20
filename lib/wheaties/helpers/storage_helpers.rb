module Wheaties
  module StorageHelpers
    private

    def decrement(key, by: 1)
      redis.decrby(key, by)
    end

    def del(key)
      redis.del(key)
    end

    def get(key, default = nil)
      redis.get(key) || default
    end

    def hexists(key, field)
      redis.hexists(key, field)
    end

    def hget(key, field, default = nil)
      redis.hget(key, field) || default
    end

    def hset(key, field, value)
      redis.hset(key, field, value)
    end

    def increment(key, by: 1)
      redis.incrby(key, by)
    end

    def jget(key, default = nil)
      if redis.exists(key)
        JSON.parse(get(key))
      else
        default
      end
    end

    def jset(key, value)
      set(key, JSON.dump(value))
    end

    def redis
      Wheaties.redis
    end

    def set(key, value)
      redis.set(key, value)
    end
  end
end
