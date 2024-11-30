module Wheaties
  PLATFORMS = {
    console: ConsolePlatform,
    discord: DiscordPlatform,
    irc: IrcPlatform,
    relay: RelayPlatform
  }

  class << self
    attr_accessor :bot, :env, :logger, :platform, :redis, :root
  end

  def self.configure(platform:)
    configure_platform(platform)
    configure_root
    configure_logger
    configure_environment
    configure_bugsnag
    configure_redis
    configure_mongoid
    load_environment
  end

  # Starts the bot. This method delegates to {#platform}, which knows how to boot its underlying bot
  # process.
  #
  # @see Wheaties::ConsolePlatform
  # @see Wheaties::DiscordPlatform
  # @see Wheaties::IrcPlatform
  # @see Wheaties::RelayPlatform
  def self.start(*args, **kwargs)
    platform.start(*args, **kwargs)
  end

  private

  def self.configure_bugsnag
    Bugsnag.configure do |config|
      config.api_key = ENV['BUGSNAG_API_KEY']
      config.app_type = Wheaties.platform.bugsnag_app_type
      config.app_version = Wheaties::VERSION
      config.notify_release_stages = %w(production staging)
      config.logger = Wheaties.logger
      config.project_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      config.release_stage = self.env
    end
  end
  private_class_method :configure_bugsnag

  def self.configure_environment
    self.env = ActiveSupport::StringInquirer.new(ENV.fetch('WHEATIES_ENV', 'development'))
    logger.info("Loading #{env} environment")
  end
  private_class_method :configure_environment

  def self.configure_logger
    self.logger ||= platform.logger
    log_level = (ENV['LOG_LEVEL'] || :info).to_sym
    self.logger.level = log_level
  end
  private_class_method :configure_logger

  def self.configure_mongoid
    Mongoid.load!(root.join('config/mongoid.yml').to_s, self.env)

    # If MONGODB_LOG_LEVEL is set, leave the Mongo loggers alone (useful if you want to set
    # Wheaties.logger to debug, but the Mongo loggers to warn in order to avoid log spam)
    unless ENV['MONGODB_LOG_LEVEL']
      Mongo::Logger.logger = Wheaties.logger
      Mongoid.logger = Wheaties.logger
    end
  end
  private_class_method :configure_mongoid

  def self.configure_platform(platform_name)
    if PLATFORMS.key?(platform_name)
      self.platform = PLATFORMS[platform_name].new
    else
      raise "#{platform_name.inspect} isn't a valid bot platform name. " \
        "Valid platform names: #{PLATFORMS.keys.join(', ')}"
    end
  end
  private_class_method :configure_platform

  def self.configure_redis
    self.redis = ConnectionPool::Wrapper.new(size: 5, timeout: 5) { Redis.new }
  end
  private_class_method :configure_redis

  def self.configure_root
    relative_path = File.join(File.dirname(__FILE__), '../..')
    self.root = Pathname.new(File.expand_path(relative_path))
  end
  private_class_method :configure_root

  def self.load_environment
    environment_config = self.root.join('config/environments', self.env)
    require environment_config.to_s
  end
  private_class_method :load_environment
end
