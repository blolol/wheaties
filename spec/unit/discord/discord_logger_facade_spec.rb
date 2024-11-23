require 'spec_helper'

describe Wheaties::DiscordLoggerFacade do
  subject { described_class.new(discordrb_logger) }

  let(:discordrb_logger) do
    # We can't use instance_double here, because we need to stub methods that are added dynamically
    # to Discordrb::Logger.
    double('Discordrb::Logger', info: nil, :mode= => nil)
  end

  describe '#level=' do
    it 'calls Discordrb::Logger#mode= with an equivalent level' do
      expect(discordrb_logger).to receive(:mode=).with(:normal).once
      subject.level = ::Logger::INFO
    end
  end

  describe '#log' do
    it 'calls the equivalent Discordrb::Logger method for each message' do
      expect(discordrb_logger).to receive(:info).with('foo bar').once
      expect(discordrb_logger).to receive(:info).with('baz qux').once
      subject.log(['foo bar', 'baz qux'], :info)
    end
  end
end
