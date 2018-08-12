RSpec::Matchers.define :be_included_in do |expected|
  match do |actual|
    expected.include?(actual)
  end

  failure_message do |actual|
    "expected #{actual.inspect} to be included in #{expected.inspect}"
  end
end
