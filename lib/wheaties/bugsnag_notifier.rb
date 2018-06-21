module Wheaties
  class BugsnagNotifier
    def initialize(error, message, severity: 'error', wheaties_tab: {})
      @error = error
      @message = message
      @severity = severity
      @wheaties_tab = wheaties_tab
    end

    def notify
      Bugsnag.notify(@error) do |report|
        report.severity = @severity

        report.user = {
          nickname: @message.user.nick,
          username: @message.user.user
        }

        report.add_tab(:wheaties, {
          bot_nickname: @message.bot.nick,
          message: @message.message,
          raw_message: @message.raw,
          target: @message.target.name
        }.merge(@wheaties_tab))
      end
    end
  end
end
