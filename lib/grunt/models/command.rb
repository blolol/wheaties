module Grunt
  module Models
    class Command
      include MongoMapper::Document
      
      set_collection_name "commands"
      
      key :name, String
      key :body, String
      key :type, String
    end
  end
end
