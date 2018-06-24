module Wheaties
  class WeightedRandom
    def initialize(enumerable)
      @enumerable = enumerable
    end

    # Select one or more random elements from the array, optionally based on
    # weights. Arguments may come in several forms:
    #
    #   %w(dog cat bird bug).random => "dog"
    #   %w(dog cat bird bug).random(2) => ["bug", "dog"]
    #   %w(dog cat bird bug).random([5, 1, 2, 2]) => most likely "dog"
    #   %w(dog cat bird bug).random(2, [5, 1, 5, 2]) => most likely ["dog", "bird"]
    #   %w(dog cat bird bug).random(count: 3, weights: [...])
    #   %w(dog cat bird bug).random(count: 10, unique: false)
    #   %w(dog cat bird bug).random(weights: :length) # Generate weights via method call on objects
    #   %w(dog cat bird bug).random { |creature| creature.length } # Generate weights via block
    #
    # If weights are not provided, all elements are equally-weighted.
    #
    # By default, <tt>:unique</tt> is +true+, and assures no element will be
    # chosen more than once. However, if you'd like to allow duplicates (for
    # example, to choose ten elements from a four-element array), set
    # <tt>:unique</tt> to +false+.
    def random(*args)
      options = if args.size == 1
        case args.first
        when Hash then args.first
        when Array, Symbol then { weights: args.first }
        else { count: args.first.to_i }
        end
      elsif args.size == 2
        { count: args[0].to_i, weights: args[1] }
      else
        {}
      end

      options.reverse_merge!(count: 1, weights: Array.new(@enumerable.length, 1), unique: true)

      if block_given?
        weights = @enumerable.map { |object| yield(object) }
        return random(options.merge(weights: weights))
      end

      if options[:weights].is_a?(Symbol)
        weights = @enumerable.map { |object| object.send(options[:weights]) }
        return random(options.merge(weights: weights))
      end

      if options[:count] == 1
        total = options[:weights].inject(0.0) { |total, weight| total + weight }
        cutoff = Kernel.rand * total

        @enumerable.zip(options[:weights]).each do |object, weight|
          return object if weight >= cutoff
          cutoff -= weight
        end

        return @enumerable.shuffle.first # Fallback if zip doesn't return
      else
        if options[:unique]
          randomize(options[:weights])[0...options[:count]]
        else
          pool = randomize(options[:weights])
          Array.new(options[:count]) { pool.random }
        end
      end
    end

    # Return a randomized permutation of the collection, optionally based on weights.
    def randomize(weights = nil)
      if block_given?
        return randomize(@enumerable.map { |object| yield(object) })
      end

      if weights.is_a?(Symbol)
        return randomize(@enumerable.map { |object| object.send(weights) })
      end

      weights = weights.nil? ? Array.new(@enumerable.length, 1.0) : weights.dup
      list = @enumerable.dup.to_a
      result = []

      until list.empty?
        result << list.random(count: 1, weights: weights)
        weights.delete_at(list.index(result.last))
        list.delete(result.last)
      end

      result
    end
  end
end
