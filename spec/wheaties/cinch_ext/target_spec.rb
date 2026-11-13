require 'spec_helper'

describe Cinch::Target do
  subject(:target) { described_class.new('#general', bot) }

  let(:bot) do
    double('bot', config: double('config', message_split_start: nil, message_split_end: nil,
      max_messages: nil), irc: irc, mask: 'Wheaties!wheaties@blolol.dev')
  end
  let(:irc) { double('irc', send: nil) }

  describe '#send' do
    it 'sends a PRIVMSG and returns nil' do
      expect(target.send('Hello world!')).to be_nil
      expect(irc).to have_received(:send).with('PRIVMSG #general :Hello world!')
    end

    it 'forwards keyword arguments' do
      expect(target.send('Hello world!', as: 'Doolan')).to be_nil
      expect(irc).to have_received(:send).with('RELAYMSG #general Doolan :Hello world!')
    end
  end

  describe '#safe_send' do
    it 'sends the sanitized text and returns nil' do
      expect(target.safe_send("Hello\x01 world!")).to be_nil
      expect(irc).to have_received(:send).with('PRIVMSG #general :Hello world!')
    end
  end
end
