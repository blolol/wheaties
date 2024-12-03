require 'spec_helper'

describe Wheaties::ChatBridge::ChatEventChannel do
  TEST_CHANNEL_MAPPINGS = {
    'test' => {
      'discord' => {
        'id' => '2',
        'name' => 'test'
      },
      'irc' => {
        'name' => '#test'
      }
    },
    'foo' => {
      'discord' => {
        'id' => 3,
        'name' => 'foo'
      },
      'irc' => {
        'name' => '#foo'
      }
    }
  }

  subject { described_class.new(origin_server, origin_channel_payload) }

  before do
    subject.instance_eval do
      def mappings
        TEST_CHANNEL_MAPPINGS
      end
    end
  end

  describe '#mapping' do
    context 'with a Discord origin channel' do
      let(:origin_server) do
        Wheaties::ChatBridge::ChatEventServer.new({
          'platform' => 'discord',
          'id' => '1',
          'name' => 'Test Server'
        })
      end

      let(:origin_channel_payload) do
        {
          'id' => '2',
          'name' => 'test',
          'type' => 'text'
        }
      end

      it 'should return the correct mapping' do
        expect(subject.mapping).to eq(TEST_CHANNEL_MAPPINGS['test'])
      end
    end

    context 'with an IRC origin channel' do
      let(:origin_server) do
        Wheaties::ChatBridge::ChatEventServer.new({
          'platform' => 'irc',
          'name' => 'irc.example.test'
        })
      end

      let(:origin_channel_payload) do
        {
          'name' => '#test'
        }
      end

      it 'should return the correct mapping' do
        expect(subject.mapping).to eq(TEST_CHANNEL_MAPPINGS['test'])
      end
    end

    context 'with a channel that can only be matched by its mapping label' do
      let(:origin_server) do
        Wheaties::ChatBridge::ChatEventServer.new({
          'platform' => 'unknown',
          'name' => 'test'
        })
      end

      let(:origin_channel_payload) do
        {
          'name' => 'foo'
        }
      end

      it 'should return the correct mapping' do
        expect(subject.mapping).to eq(TEST_CHANNEL_MAPPINGS['foo'])
      end
    end

    context 'with a channel that cannot be mapped' do
      let(:origin_server) do
        Wheaties::ChatBridge::ChatEventServer.new({
          'platform' => 'unknown',
          'name' => 'test'
        })
      end

      let(:origin_channel_payload) do
        {
          'name' => 'unknown'
        }
      end

      it 'should raise a ChannelMappingNotFoundError' do
        expect { subject.mapping }.to raise_error(Wheaties::ChatBridge::ChannelMappingNotFoundError)
      end
    end
  end

  describe '#name' do
    let(:origin_server) do
      Wheaties::ChatBridge::ChatEventServer.new({
        'platform' => 'discord',
        'id' => '1',
        'name' => 'Test Server'
      })
    end

    let(:origin_channel_payload) do
      {
        'id' => '2',
        'name' => 'test',
        'type' => 'text'
      }
    end

    it 'should return the name for the corresponding platform' do
      expect(subject.name(platform: 'discord')).to eq('test')
      expect(subject.name(platform: 'irc')).to eq('#test')
      expect(subject.name(platform: 'unknown')).to be_nil
    end
  end

  describe '#on' do
    let(:origin_server) do
      Wheaties::ChatBridge::ChatEventServer.new({
        'platform' => 'discord',
        'id' => '1',
        'name' => 'Test Server'
      })
    end

    let(:origin_channel_payload) do
      {
        'id' => '2',
        'name' => 'test',
        'type' => 'text'
      }
    end

    it 'should return the mapping for the corresponding platform' do
      expect(subject.on('discord')).to eq(TEST_CHANNEL_MAPPINGS.dig('test', 'discord'))
      expect(subject.on('irc')).to eq(TEST_CHANNEL_MAPPINGS.dig('test', 'irc'))
      expect(subject.on('unknown')).to be_nil
    end
  end
end
