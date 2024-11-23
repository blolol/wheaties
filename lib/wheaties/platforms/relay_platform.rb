module Wheaties
  class RelayPlatform
    # The app type to use when configuring Bugsnag.
    #
    # @return [String] the string `"relay"`
    def bugsnag_app_type
      'relay'
    end

    # The logger to use.
    #
    # @return [::Logger] an instance of {::Logger} connected to standard output
    # @see Wheaties.configure_logger
    def logger
      ::Logger.new($stdout)
    end

    # Starts the relay.
    def start(queue_url, wait_time_seconds:)
      Relay::ChatRelay.new(queue_url, wait_time_seconds: wait_time_seconds).start
    end
  end
end
