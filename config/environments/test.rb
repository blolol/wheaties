Wheaties.logger.level = :debug

# Log MongoDB activity
Mongo::Logger.logger = Wheaties.logger
Mongoid.logger = Wheaties.logger
