module Grunt
  class << self
    attr_accessor :config
    attr_reader :history, :redis

    def start
      load_defaults
      load_parser
      load_database
      load_history
      load_redis
    end

    def load_defaults
      grunt_config_path = Wheaties.root.join("config/grunt.yml")
      Grunt.config = YAML.load_file(grunt_config_path) || {}
    end

    def load_parser
      Treetop.load(File.join(File.dirname(__FILE__), "arguments"))
    end

    def load_database
      environment = "production"
      database_config = { environment => Grunt.config["database"] }
      MongoMapper.setup(database_config, environment)
    end

    def load_history
      @history = {}
      history.instance_eval do
        def max_size=(max_size)
          @max_size = max_size
        end

        def max_size
          @max_size
        end

        def <<(response)
          return unless response.kind_of?(Wheaties::ResponseTypes::OnPrivmsg)
          return if response.pm?

          history = (self[response.channel] ||= [])
          history.pop if history.size >= max_size
          history.unshift(response.dup)
        end
      end
      history.max_size = (Grunt.config["history"] || 50).to_i
    end

    def load_redis
      if redis_url = Grunt.config["redis"]
        require "redis"
        @redis = Redis.new(url: redis_url)
        Wheaties.logger.info "[Grunt] Connected to Redis at #{redis_url}"
      end
    end
  end

  self.start
end
