class Range
  # Choose one or more random elements from the receiver based on the weights
  # provided. If _weights_ is nil, then each element is weighed equally.
  #
  # See Array#random for examples.
  def random(count = 1, weights = nil)
    to_a.random(count, weights)
  end
end
