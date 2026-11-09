require 'spec_helper'

describe Wheaties::InvocationArguments do
  let(:options) { {} }
  let(:arguments) { described_class.new(parsed_arguments, 'unparsed') }

  subject(:remaining) do
    arguments.parse_options(into: options) do |parser|
      parser.on('-m', '--model [MODEL]', String)
      parser.on('-u', '--unique')
    end
  end

  describe '#parse_options' do
    context 'with no switches' do
      let(:parsed_arguments) { %w(generate a picture of a dog) }

      it 'preserves repeated arguments' do
        expect(remaining).to eq(%w(generate a picture of a dog))
      end
    end

    context 'with a switch and its value' do
      let(:parsed_arguments) { %w(-m foo x y) }

      it 'removes the switch and value, and stores the value in the options' do
        expect(remaining).to eq(%w(x y))
        expect(options).to eq(model: 'foo')
      end
    end

    context 'with a switch value that is repeated as a positional argument' do
      let(:parsed_arguments) { %w(x -m x x) }

      it 'only removes the value consumed by the switch' do
        expect(remaining).to eq(%w(x x))
        expect(options).to eq(model: 'x')
      end
    end

    context 'with repeated positional arguments around switches' do
      let(:parsed_arguments) { %w(ha -u ha ha) }

      it 'preserves every positional argument' do
        expect(remaining).to eq(%w(ha ha ha))
        expect(options).to eq(unique: true)
      end
    end

    context 'with non-String arguments' do
      let(:parsed_arguments) { [1, '1', 1, 2.5, %w(a b), %w(a b)] }

      it 'returns the original objects, in order' do
        expect(remaining).to eq([1, '1', 1, 2.5, %w(a b), %w(a b)])
        expect(remaining.map(&:class)).to eq([Integer, String, Integer, Float, Array, Array])
      end
    end

    context 'with a non-String switch value' do
      let(:parsed_arguments) { ['-m', 5, 5] }

      it 'removes the consumed value and keeps the rest' do
        expect(remaining).to eq([5])
        expect(options).to eq(model: '5')
      end
    end

    it 'returns InvocationArguments that keep the unparsed string' do
      arguments = described_class.new(%w(a a), 'a a')
      result = arguments.parse_options { |parser| parser.on('-u') }

      expect(result).to be_a(described_class)
      expect(result.unparsed).to eq('a a')
    end
  end
end
