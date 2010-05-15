module Grunt
  class << self
    attr_accessor :config
    
    def start
      load_defaults
      load_parser
    end
    
    def load_defaults
      grunt_config_path = Wheaties.root.join("config/grunt.yml")
      Grunt.config = YAML.load_file(grunt_config_path) || {}
    end
    
    def load_parser
      Treetop.load("command")
    end
  end
  
  self.start
end
