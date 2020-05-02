class Command
  include Mongoid::Document
  include Mongoid::Timestamps

  # Attributes
  attr_accessor :find_by_regex_match_data

  # Fields
  field :body, type: String, default: ''
  field :created_by, type: String
  field :desc, type: String
  field :events, type: Array, default: []
  field :help, type: Array
  field :name, type: String
  field :regex, type: Boolean, default: false
  field :updated_by, type: String
  field :url_title, type: String
  field :usage, type: String
  field :used_at, type: Time
  field :used_by, type: String
  field :uses, type: Integer, default: 0

  # Callbacks
  before_create :generate_description
  before_create :generate_url_title

  def self.find_by_name(name)
    command_cache.get(name) || not_found!(name)
  rescue Mongoid::Errors::DocumentNotFound
    not_found!(name)
  end

  def self.find_by_regex(input)
    where(regex: true).for_js('input.match(this.name)', input: input).first.tap do |command|
      command.find_by_regex_match_data = input.match(command.name) if command
    end
  end

  def assign_value(value, message)
    raise("#assign_value is not implemented by #{self.class.name}")
  end

  def built_in?
    false
  end

  def invoke(environment)
    Wheaties::NullInvocationResult.new
  end

  def update_usage_stats(used_by:)
    timeless.update_attributes(used_at: Time.current, used_by: used_by, uses: uses + 1)
  end

  def url
    "#{ENV['WHEATIES_BASE_URL']}/c/#{url_title}"
  end

  private

  def self.command_cache
    Thread.current[:wheaties_command_cache] ||= Wheaties::CommandCache.new
  end
  private_class_method :command_cache

  def self.not_found!(name)
    raise(Wheaties::CommandNotFoundError.new(command_name: name))
  end
  private_class_method :not_found!

  def generate_description
    self.desc = body.lines.first.strip
  end

  def generate_url_title
    digest = Digest::SHA256.hexdigest(name).first(5)
    self.url_title = "#{digest}-#{name.parameterize}"
  end
end
