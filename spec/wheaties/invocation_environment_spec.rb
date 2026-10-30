require 'spec_helper'

describe Wheaties::InvocationEnvironment do
  # Builds a stand-in for a Command whose body is evaluated by the environment
  def build_command(name, body)
    double(name, name: name, body: body, update_usage_stats: nil)
  end

  let(:stack) { [] }
  let(:message) { double('message', user: double('user', nick: 'nick')) }
  let(:invocation) do
    double('invocation', arguments: [], event: :command, message: message, stack: stack)
  end
  let(:environment) { described_class.new(invocation) }

  describe '#eval' do
    before do
      # Not `.with(:helper)`: ActiveSupport's Object#with shadows rspec 3.7's matcher method
      allow(Command).to receive(:find_by_name) { build_command('helper', '42') }
    end

    it 'pushes the invocation onto the stack while the command runs' do
      command = build_command('outer', 'stack.dup')

      expect(environment.eval(command)).to eq([invocation])
    end

    it 'pops the invocation off the stack when the command finishes' do
      environment.eval(build_command('outer', '1'))

      expect(stack).to be_empty
    end

    it 'leaves top? true after the command calls another command' do
      # Runs the called command the way CommandInvocation would, sharing the caller's stack
      allow(Wheaties::CommandInvocation).to receive(:new) do |*args|
        command, options = args[1], args.last
        helper_invocation = double('helper', arguments: [], event: :command, message: message,
          stack: options[:stack])
        double('helper invocation',
          result: double(ruby_value: described_class.new(helper_invocation).eval(command)))
      end

      command = build_command('outer', "helper; top?")

      expect(environment.eval(command)).to be(true)
      expect(stack).to be_empty
    end

    it 'pops the invocation when the command halts' do
      environment.eval(build_command('outer', 'halt("done")'))

      expect(stack).to be_empty
    end

    it 'leaves the invocation on the stack when the command raises' do
      expect { environment.eval(build_command('outer', 'raise "boom"')) }.to raise_error('boom')

      expect(stack).to eq([invocation])
    end
  end
end
