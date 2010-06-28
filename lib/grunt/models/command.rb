module Grunt
  module Models
    class Command
      include MongoMapper::Document
      
      set_collection_name "commands"
      
      key :name, String, :required => true, :unique => true
      key :name_is_regex, Boolean, :default => false
      key :url_title, String, :unique => true
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
      
      validates_format_of :name, :with => /^[a-zA-Z0-9_\-\?\!]+$/,
                          :message => "may contain only alphanumeric characters, " +
                                      "underscores, hyphens, question marks and " +
                                      "exclamation points"
      
      before_save :update_metadata
      before_create :update_url_title
      
      def used!(nick)
        self.used_by = nick
        self.used_at = Time.now
        self.uses += 1
        save
      end
      
      def update_url_title
        self.url_title = "#{rand(999).to_i}_#{self.name.parameterize}"
      end
      
      protected
        def update_metadata
          metadata_method = "update_#{type}_metadata"
          send(metadata_method) if respond_to?(metadata_method)
        end

        def update_plain_text_metadata
          self.desc = self.body.split("\n").first
        end
      
      class << self
        def find_by_regex(name)
          all(:name_is_regex => true).each do |command|
            if match = name.match(/#{command.name}/i)
              return { :command => command, :match => match }
            end
          end
          nil
        end # find_by_regex
      end # class << self
    end # Command
  end # Models
end
