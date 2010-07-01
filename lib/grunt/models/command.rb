class Command
  include MongoMapper::Document
  
  set_collection_name "commands"
  
  key :_type, String
  key :name, String, :required => true, :unique => true
  key :regex, Boolean, :default => false
  key :url_title, String, :unique => true
  key :body, String, :required => true
  key :desc, String
  key :usage, String
  key :help, Array
  key :events, Array, :default => []
  key :uses, Integer, :default => 0
  key :used_by, String
  key :used_at, Time
  key :created_by, String, :required => true
  key :updated_by, String
  timestamps!

  validates_format_of :name, :with => /^[a-zA-Z0-9_\^\$\:\[\]\(\)\{\}\.\*\+\-\?\!\,\/\\]+$/,
                      :message => "may only contain letters, numbers and common regex symbols"
  
  before_create :update_metadata
  before_create :update_url_title
  
  def update_url_title
    hex = Digest::SHA1.hexdigest(name)[0..5]
    title = name.gsub("_", "-").parameterize
    self.url_title = hex + (title =~ /^[\-\s]*$/ ? "" : "-#{title}")
  end
  
  def update_metadata
    self.class.update_metadata(self)
  end
  
  def used!(nick)
    self.used_by = nick
    self.used_at = Time.now
    self.uses += 1
    save
  end
  
  def eval!(context); end
  
  class << self
    def first_by_regex(name)
      all(:regex => true).each do |command|
        if match = name.match(/#{command.name}/i)
          command.instance_eval! do
            def match=(match)
              @match = match.dup
            end
            
            def match
              @match
            end
          end
          command.match = match
          return command
        end
      end
      nil
    end
    
    def humanize_as(name)
      @humanize_as = name
    end

    def humanize
      @humanize_as
    end
    
    def update_metadata(command); end
  end # class << self
end

class PlainTextCommand < Command
  humanize_as "Plain Text"
  
  def self.update_metadata(command)
    command.desc = command.body.strip.split("\n").first
  end
end

class RandomLineCommand < Command
  humanize_as "Random Line"
  
  def self.update_metadata(command)
    command.desc = command.body.strip.split("\n").first
  end
end

class RubyCommand < Command
  humanize_as "Ruby"
  
  def self.update_metadata(command)
    command.desc = command.body.strip.split("\n").first[/^\s*#\s*(.*?)\s*$/, 1]
    command.usage = command.body[/^\s*#\s*Usage:\s*(.*?)\s*$/i, 1]
    command.help = command.body.scan(/^\s*#\s*Help:\s*(.*?)\s*$/i).flatten
  end
end

class YamlCommand < Command
  humanize_as "YAML"
  
  def self.update_metadata(command)
    command.desc = command.body.strip.split("\n").first[/^\s*#\s*(.*?)\s*$/, 1]
  end
end
