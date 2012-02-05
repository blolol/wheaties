module Grunt
  class << self
    attr_accessor :config
    attr_reader :history
    
    def start
      load_defaults
      load_parser
      load_database
      load_history
    end
    
    def load_defaults
      grunt_config_path = Wheaties.root.join("config/grunt.yml")
      Grunt.config = YAML.load_file(grunt_config_path) || {}
    end
    
    def load_parser
      Treetop.load(File.join(File.dirname(__FILE__), "arguments"))
    end
    
    def load_database
      host = Grunt.config["database"]["host"]
      database = Grunt.config["database"]["database"]
      
      MongoMapper.connection = Mongo::Connection.new(host)
      MongoMapper.database = database
      
      if Grunt.config["database"]["username"] && Grunt.config["database"]["password"]
        MongoMapper.database.authenticate(Grunt.config["database"]["username"], Grunt.config["database"]["password"])
      end
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
  end
  
  self.start
end
