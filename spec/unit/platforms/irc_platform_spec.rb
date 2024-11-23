require 'spec_helper'

describe Wheaties::IrcPlatform do
  describe '#bugsnag_app_type' do
    subject { described_class.new.bugsnag_app_type }

    it 'returns the expected value' do
      expect(subject).to eq('irc')
    end
  end

  describe '#logger' do
    subject { described_class.new.logger }

    it 'returns an instance of Wheaties::Logger' do
      expect(subject).to be_instance_of(Wheaties::Logger)
    end
  end

  describe '#start' do
    subject { described_class.new.start }

    before do
      Wheaties.bot = instance_double('Cinch::Bot', start: nil)
    end

    after do
      Wheaties.bot = nil
    end

    it 'calls #start on Wheaties.bot' do
      expect(Wheaties.bot).to receive(:start).once
      subject
    end
  end
end
