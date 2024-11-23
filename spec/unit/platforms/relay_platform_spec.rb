require 'spec_helper'

describe Wheaties::RelayPlatform do
  describe '#bugsnag_app_type' do
    subject { described_class.new.bugsnag_app_type }

    it 'returns the expected value' do
      expect(subject).to eq('relay')
    end
  end

  describe '#logger' do
    subject { described_class.new.logger }

    it 'returns an instance of Logger' do
      expect(subject).to be_kind_of(::Logger)
    end
  end

  describe '#start' do
    subject { described_class.new.start('queue-url', wait_time_seconds: 15) }

    let(:relay) { instance_double('Wheaties::Relay::ChatRelay', start: nil ) }

    before do
      allow(Wheaties::Relay::ChatRelay).to receive(:new).and_return(relay)
    end

    it 'instantiates a new ChatRelay and starts it' do
      expect(Wheaties::Relay::ChatRelay).to receive(:new).with('queue-url',
        wait_time_seconds: 15).once
      expect(relay).to receive(:start).once
      subject
    end
  end
end
