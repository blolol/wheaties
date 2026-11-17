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

  %w(-f --find -g --grep).each do |switch|
    context "with #{switch} and a string" do
      let(:parsed_arguments) { [switch, 'T', '-a'] }

      it 'returns lines containing the string, case-insensitively' do
        expect(result).to eq(%w(two three))
      end
    end

    context "with #{switch} and a regexp" do
      let(:parsed_arguments) { [switch, /^t.o$/, '-a'] }

      it 'returns lines matching the regexp' do
        expect(result).to eq('two')
      end
    end
  end

  context 'with --find and no matching lines' do
    let(:parsed_arguments) { %w(--find nope) }

    it 'returns no lines' do
      expect(result).to eq([])
    end
  end

  context 'with URL filters' do
    let(:text) do
      <<~EOS
        just some text
        https://example.com/page.html
        https://example.com/still.PNG
        look: https://example.com/photo.jpg?width=500 nice
        https://example.com/dance.gif and https://example.com/loop.webp
        https://i.imgur.com/abc.gifv#t=1
        https://example.com/notagif.gif.html
      EOS
    end

    context 'with --img' do
      let(:parsed_arguments) { %w(--img -a) }

      it 'returns only the still or animated image URLs' do
        expect(result).to eq(%w(
          https://example.com/still.PNG
          https://example.com/photo.jpg?width=500
          https://example.com/dance.gif
          https://example.com/loop.webp
          https://i.imgur.com/abc.gifv#t=1
        ))
      end
    end

    context 'with --gif' do
      let(:parsed_arguments) { %w(--gif -a) }

      it 'returns only the animated image URLs' do
        expect(result).to eq(%w(
          https://example.com/dance.gif
          https://example.com/loop.webp
          https://i.imgur.com/abc.gifv#t=1
        ))
      end
    end

    context 'with --img and --gif' do
      let(:parsed_arguments) { %w(--img --gif -a) }

      it 'returns only the animated image URLs' do
        expect(result).to eq(%w(
          https://example.com/dance.gif
          https://example.com/loop.webp
          https://i.imgur.com/abc.gifv#t=1
        ))
      end
    end

    context 'with --img and --find' do
      let(:parsed_arguments) { %w(--img --find photo -a) }

      it 'finds within the extracted URLs' do
        expect(result).to eq('https://example.com/photo.jpg?width=500')
      end
    end
  end

  { 'ascending' => %w(one three two), 'asc' => %w(one three two),
    'descending' => %w(two three one), 'desc' => %w(two three one) }.each do |order, expected|
    context "with --sort #{order}" do
      let(:parsed_arguments) { ['--sort', order, '-a'] }

      it 'sorts the lines' do
        expect(result).to eq(expected)
      end
    end
  end

  context 'with --sort in a different case' do
    let(:parsed_arguments) { %w(-s DESC -a) }

    it 'sorts the lines' do
      expect(result).to eq(%w(two three one))
    end
  end

  %w(random rand).each do |order|
    context "with --sort #{order}" do
      let(:parsed_arguments) { ['--sort', order, '-a'] }

      it 'shuffles the lines' do
        allow_any_instance_of(Array).to receive(:shuffle) { |lines| lines.reverse }
        expect(result).to eq(%w(three two one))
      end
    end
  end

  %w(-r --random).each do |switch|
    context "with #{switch}" do
      let(:parsed_arguments) { [switch, '-a'] }

      it 'shuffles the lines' do
        allow_any_instance_of(Array).to receive(:shuffle) { |lines| lines.reverse }
        expect(result).to eq(%w(three two one))
      end
    end
  end

  context 'with --random and --sort' do
    let(:parsed_arguments) { %w(--random --sort asc -a) }

    it 'shuffles the lines, ignoring --sort' do
      allow_any_instance_of(Array).to receive(:shuffle) { |lines| lines.reverse }
      expect(result).to eq(%w(three two one))
    end
  end

  context 'with an unknown --sort order' do
    let(:parsed_arguments) { %w(--sort sideways -a) }

    it 'keeps the original order' do
      expect(result).to eq(%w(one two three))
    end
  end

  context 'with --find, --sort and --count together' do
    let(:parsed_arguments) { %w(--find t --sort asc --count 1) }

    it 'filters, then sorts, then limits' do
      expect(result).to eq('three')
    end
  end

  context 'with a default sort order' do
    let(:default_options) { { count: 1, sort: 'random' } }
    let(:parsed_arguments) { %w(--sort desc) }

    it 'lets the switch override it' do
      expect(result).to eq('two')
    end
  end
end
