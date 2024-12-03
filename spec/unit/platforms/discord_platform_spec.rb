require 'spec_helper'

describe Wheaties::DiscordPlatform do
  describe '#bugsnag_app_type' do
    subject { described_class.new.bugsnag_app_type }

    it 'returns the expected value' do
      expect(subject).to eq('discord')
    end
  end

  describe '#logger' do
    subject { described_class.new.logger }

    it 'returns an instance of DiscordLoggerFacade' do
      expect(subject).to be_kind_of(Wheaties::DiscordLoggerFacade)
    end
  end

  describe '#start' do
    subject { described_class.new.start }

    let(:discord_chat_bridge_receiver) do
      instance_double('Wheaties::Discord::ChatBridge::Receive::Receiver', start: nil)
    end

    before do
      Wheaties.bot = instance_double('Discordrb::Bot', run: nil)
      allow(Wheaties::Discord::ChatBridge::Receive::Receiver).to receive(:new).
        and_return(discord_chat_bridge_receiver)
    end

    after do
      Wheaties.bot = nil
    end

    it 'starts the Discordrb bot and the Discord relay subscriber' do
      expect(Wheaties.bot).to receive(:run).with(true).once
      expect(discord_chat_bridge_receiver).to receive(:start).once
      subject
    end
  end
end
