require 'spec_helper'

describe Wheaties::CdnHelpers::DataNormalizer do
  let(:normalizer) { described_class.new(data) }

  context 'with a data URL without a media type that is not base64-encoded' do
    let(:data) { 'data:,foo%20bar' }

    it 'returns the default content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=US-ASCII')
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo%20bar')
    end
  end

  context 'with a data URL without a media type that is base64-encoded' do
    let(:data) { 'data:;base64,Zm9vIGJhcg==' }

    it 'returns the default content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=US-ASCII')
    end

    it 'returns an IO-like stream containing the decoded data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end

  context 'with a data URL with a parameterless media type that is not base64-encoded' do
    let(:data) { 'data:text/plain,foo%20bar' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain')
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo%20bar')
    end
  end

  context 'with a data URL with a parameterless media type that is base64-encoded' do
    let(:data) { 'data:text/plain;base64,Zm9vIGJhcg==' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain')
    end

    it 'returns an IO-like stream containing the decoded data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end

  context 'with a data URL with a single-parameter media type that is not base64-encoded' do
    let(:data) { 'data:text/plain;charset=UTF-8,foo%20bar' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=UTF-8')
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo%20bar')
    end
  end

  context 'with a data URL with a single-parameter media type that is base64-encoded' do
    let(:data) { 'data:text/plain;charset=UTF-8;base64,Zm9vIGJhcg==' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=UTF-8')
    end

    it 'returns an IO-like stream containing the decoded data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end

  context 'with a data URL with a multi-parameter media type that is not base64-encoded' do
    let(:data) { 'data:text/plain;charset=UTF-8;foo=bar,foo%20bar' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=UTF-8;foo=bar')
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo%20bar')
    end
  end

  context 'with a data URL with a multi-parameter media type that is base64-encoded' do
    let(:data) { 'data:text/plain;charset=UTF-8;foo=bar;base64,Zm9vIGJhcg==' }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain;charset=UTF-8;foo=bar')
    end

    it 'returns an IO-like stream containing the decoded data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end

  context 'with a string that is not a data URL' do
    let(:data) { 'foo bar' }

    it 'returns a content type based on the string encoding' do
      expect(normalizer.content_type).to eq("text/plain;charset=#{data.encoding.name}")
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end

  context 'with a StringIO that is a data URL' do
    let(:data) { StringIO.new('data:text/plain,foo%20bar') }

    it 'returns the specified content type' do
      expect(normalizer.content_type).to eq('text/plain')
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo%20bar')
    end
  end

  context 'with a StringIO that is not a data URL' do
    let(:data) { StringIO.new('foo bar') }

    it 'returns a content type based on the stream encoding' do
      expect(normalizer.content_type).to eq("text/plain;charset=#{data.external_encoding.name}")
    end

    it 'returns an IO-like stream containing the data' do
      expect(normalizer.data_stream.read).to eq('foo bar')
    end
  end
end
