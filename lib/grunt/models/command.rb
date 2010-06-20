module Grunt
  module Models
    class Command
      include MongoMapper::Document
      
      set_collection_name "commands"
      
      key :name, String, :required => true, :unique => true
      key :body, String, :required => true
      key :desc, String
      key :usage, String
      key :help, Array
      key :type, String, :required => true
      key :events, Array
      key :uses, Integer, :default => 0
      key :used_by, String
      key :used_at, Time
      key :created_by, String
      key :updated_by, String
      timestamps!
      
      validates_format_of :name, :with => /^[a-zA-Z0-9_\-]+$/,
                          :message => "may contain only alphanumeric characters, underscores and hyphens"
      
      before_save :update_metadata
      
      def used!(nick)
        self.used_by = nick
        self.used_at = Time.now
        self.uses += 1
        save
      end
      
      protected
        def update_metadata
          metadata_method = "update_#{type}_metadata"
          send(metadata_method) if respond_to?(metadata_method)
        end

        def update_plain_text_metadata
          self.desc = self.body.split("\n").first
        end
    end
  end
end
