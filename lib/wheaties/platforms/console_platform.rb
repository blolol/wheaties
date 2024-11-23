module Wheaties
  class ConsolePlatform
    def bugsnag_app_type
      'console'
    end

    def logger
      ::Logger.new($stdout)
    end

    def start
      # Do nothing
    end
  end
end
