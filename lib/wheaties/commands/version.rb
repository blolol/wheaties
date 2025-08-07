class Version
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :body, type: String
  field :commit_message, type: String
  field :created_by, type: String
  field :events, type: Array
  field :name, type: String
  field :regex, type: Boolean
  field :url_title, type: String

  # Callbacks
  before_save :set_url_title

  # Associations
  embedded_in :command

  def to_param
    url_title
  end

  private

  def set_url_title
    hash_content = name + Time.now.iso8601 + body + created_by + commit_message.to_s
    self.url_title = Digest::SHA1.hexdigest(hash_content).first(6)
  end
end
