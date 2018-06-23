module Wheaties
  class << self
    attr_accessor :redis, :root
  end

  def self.boot
    configure_root
    configure_bugsnag
    configure_redis
    configure_mongoid
  end

  private

  def self.configure_bugsnag
    Bugsnag.configure do |config|
      config.api_key = ENV['BUGSNAG_API_KEY']
      config.app_type = 'cinch'
      config.app_version = Wheaties::VERSION
      config.notify_release_stages = %w(production staging)
      config.project_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      config.release_stage = ENV.fetch('WHEATIES_ENV', 'development')
    end
  end
  private_class_method :configure_bugsnag

  def self.configure_mongoid
    Mongoid.load!(root.join('config/mongoid.yml').to_s)
  end
  private_class_method :configure_mongoid

  def self.configure_redis
    self.redis = ConnectionPool::Wrapper.new(size: 5, timeout: 5) { Redis.new }
  end
  private_class_method :configure_redis

  def self.configure_root
    relative_path = File.join(File.dirname(__FILE__), '../..')
    self.root = Pathname.new(File.expand_path(relative_path))
  end
  private_class_method :configure_root
end

Wheaties.boot
