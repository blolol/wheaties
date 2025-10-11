require 'spec_helper'

describe Wheaties::WeightedRandom do
  describe '#random' do
    subject { described_class.new(enumerable).random(*arguments) }

    let(:enumerable) { %w(dog cat bird bug) }
    let(:arguments) { [] }

    context 'without any arguments' do
      it 'returns a random element from the array' do
        expect(subject).to be_included_in(enumerable)
      end
    end

    context 'with a positional count argument' do
      let(:arguments) { [2] }

      it 'returns two random elements from the array' do
        subject.each do |element|
          expect(element).to be_included_in(enumerable)
        end
      end
    end

    context 'with a positional weights argument' do
      let(:arguments) { [[1, 0, 0, 0]] }

      it 'returns a random element from the array according to the weights' do
        expect(subject).to eq('dog')
      end
    end

    context 'with both positional count and weights arguments' do
      let(:arguments) { [2, [1, 0, 0, 1]] }

      it 'returns two random elements from the array according to the weights' do
        expect(subject).to match_array(['dog', 'bug'])
      end
    end

    context 'with named count and weights arguments' do
      let(:arguments) { [{ count: 2, weights: [1, 1, 0, 0] }] }

      it 'returns two random elements from the array according to the weights' do
        expect(subject).to match_array(['dog', 'cat'])
      end
    end

    context 'when duplicates are allowed' do
      let(:arguments) { [{ count: 2, weights: [1, 0, 0, 0], unique: false }] }

      it 'returns two duplicate random elements according to the weights' do
        expect(subject).to eq(['dog', 'dog'])
      end
    end

    context 'when the enumerable is a Range' do
      let(:enumerable) { 1..10 }

      it 'returns a random element from the Range' do
        expect(subject).to be_included_in(enumerable)
      end
    end
  end
end
