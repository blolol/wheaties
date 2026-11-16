require 'spec_helper'

describe Wheaties::PlainTextInvocationResult do
  let(:text) { "one\ntwo\nthree\n" }
  let(:arguments) { Wheaties::InvocationArguments.new(parsed_arguments, 'unparsed') }
  let(:default_options) { { count: 1 } }

  subject(:result) { described_class.new(text, arguments, default_options).ruby_value }

  context 'with no switches' do
    let(:parsed_arguments) { [] }

    it 'returns the default count of lines' do
      expect(result).to eq('one')
    end
  end

  context 'with --count' do
    let(:parsed_arguments) { %w(-c 2) }

    it 'returns that many lines' do
      expect(result).to eq(%w(one two))
    end
  end

  %w(-a --all).each do |switch|
    context "with #{switch}" do
      let(:parsed_arguments) { [switch] }

      it 'returns every line' do
        expect(result).to eq(%w(one two three))
      end
    end
  end

  context 'with --all and --count' do
    let(:parsed_arguments) { %w(--all -c 2) }

    it 'returns every line, ignoring --count' do
      expect(result).to eq(%w(one two three))
    end
  end
end
