require 'spec_helper'

describe Wheaties::ConsolePlatform do
  describe '#bugsnag_app_type' do
    subject { described_class.new.bugsnag_app_type }

    it 'returns the expected value' do
      expect(subject).to eq('console')
    end
  end

  describe '#logger' do
    subject { described_class.new.logger }

    it 'returns an instance of Logger' do
      expect(subject).to be_a(::Logger)
    end
  end
end
