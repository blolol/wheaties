module Enumerable
  def random(*args)
    Wheaties::WeightedRandom.new(self).random(*args)
  end

  def randomize(*args)
    Wheaties::WeightedRandom.new(self).randomize(*args)
  end
end
