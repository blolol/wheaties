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
    end
    
    def load_history
      @history = {}
    end
  end
  
  self.start
end
