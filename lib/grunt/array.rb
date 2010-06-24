class Array
  # Choose one or more random elements from the receiver based on the weights
  # provided. If _weights_ is nil, then each element is weighed equally.
  # 
  #   [1,2,3].random          #=> 2
  #   [1,2,3].random          #=> 1
  #   [1,2,3].random          #=> 3
  #   [1,2,3].random(2)       #=> [2,1]
  #
  # If _weights_ is an array, then each element of the receiver gets its
  # weight from the corresponding element of _weights_. Notice that it
  # favors the element with the highest weight.
  #
  #   [1,2,3].random(1, [1,4,1]) #=> 2
  #   [1,2,3].random(1, [1,4,1]) #=> 1
  #   [1,2,3].random(1, [1,4,1]) #=> 2
  #   [1,2,3].random(1, [1,4,1]) #=> 2
  #   [1,2,3].random(1, [1,4,1]) #=> 3
  #
  # If _weights_ is a symbol, the weight array is constructed by calling
  # the appropriate method on each array element in turn. Notice that
  # it favors the longer word when using :length.
  #
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "dog"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "hippopotamus"
  #   ['dog', 'cat', 'hippopotamus'].random(:length) #=> "cat"
  #
  # Modified from http://snippets.dzone.com/posts/show/898.
  def random(count = 1, weights = nil)
    if count == 1
      return random(count, map { |n| n.send(weights) }) if weights.is_a?(Symbol)
    
      weights ||= Array.new(length, 1.0)
      total = weights.inject(0.0) { |t, w| t + w }
      point = Kernel.rand * total
    
      zip(weights).each do |n, w|
        return n if w >= point
        point -= w
      end
    else
      count = [self.size, count].min
      randomize(weights)[0...count]
    end
  end
  
  # Generates a permutation of the receiver based on _weights_ as in
  # Array#random. Notice that it favors the element with the highest
  # weight.
  #
  #   [1,2,3].randomize           #=> [2,1,3]
  #   [1,2,3].randomize           #=> [1,3,2]
  #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
  #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
  #   [1,2,3].randomize([1,4,1])  #=> [1,2,3]
  #   [1,2,3].randomize([1,4,1])  #=> [2,3,1]
  #   [1,2,3].randomize([1,4,1])  #=> [3,2,1]
  #   [1,2,3].randomize([1,4,1])  #=> [2,1,3]
  #
  # Stolen from http://snippets.dzone.com/posts/show/898.
  def randomize(weights = nil)
    return randomize(map { |n| n.send(weights) }) if weights.is_a?(Symbol)
    
    weights = weights.nil? ? Array.new(length, 1.0) : weights.dup
    
    list, result = self.dup, []
    until list.empty?
      result << list.random(1, weights)
      weights.delete_at(list.index(result.last))
      list.delete result.last
    end
    
    result
  end
end
