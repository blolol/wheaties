class Command
  include Mongoid::Document

  # Fields
  field :body, type: String
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

  def self.find_by_name(name)
    command_cache.get(name)
  rescue Mongoid::Errors::DocumentNotFound
    raise Wheaties::CommandNotFoundError.new(command_name: name)
  end

  def invoke(environment)
    Wheaties::NullInvocationResult.new
  end

  def update_usage_stats(used_by:)
    update_attributes(used_at: Time.current, used_by: used_by, uses: uses + 1)
  end

  def url
    "#{ENV['WHEATIES_BASE_URL']}/commands/#{url_title}"
  end

  private

  def self.command_cache
    Thread.current[:wheaties_command_cache] ||= Wheaties::CommandCache.new
  end
  private_class_method :command_cache
end
