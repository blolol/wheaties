module Grunt
  module Extensions
    module Array
      # Select one or more random elements from the array, optionally based on
      # weights. Arguments may come in several forms:
      #
      #   %w(dog cat bird bug).random => "dog"
      #   %w(dog cat bird bug).random(2) => ["bug", "dog"]
      #   %w(dog cat bird bug).random([5, 1, 2, 2]) => most likely "dog"
      #   %w(dog cat bird bug).random(2, [5, 1, 5, 2]) => most likely ["dog", "bird"]
      #   %w(dog cat bird bug).random :count => 3, :weights => [...]
      #   %w(dog cat bird bug).random :count => 10, :unique => false
      #
      # If weights are not provided, all elements are equally-weighted.
      #
      # By default, <tt>:unique</tt> is +true+, and assures no element will be
      # chosen more than once. However, if you'd like to allow duplicates (for
      # example, to choose ten elements from a four-element array), set
      # <tt>:unique</tt> to +false+.
      #
      # TODO: Document using a symbol or a block to compute weights.
      def random(*args)
        options = if args.size == 1
                    case args.first
                    when Hash then args.first
                    when Array, Symbol then { :weights => args.first }
                    else { :count => args.first.to_i }
                    end
                  elsif args.size == 2
                    { :count => args[0].to_i, :weights => args[1] }
                  else {}; end
        options.reverse_merge! :count => 1,
                               :weights => ::Array.new(length, 1),
                               :unique => true
        
        if block_given?
          weights = map { |o| yield o }
          return random(options.merge(:weights => weights))
        end
        
        if options[:weights].is_a?(Symbol)
          weights = map { |o| o.send(options[:weights]) }
          return random(options.merge(:weights => weights))
        end
        
        if options[:count] == 1
          total = options[:weights].inject(0.0) { |t, w| t + w }
          cutoff = Kernel.rand * total
          
          zip(options[:weights]).each do |n, w|
            return n if w >= cutoff
            cutoff -= w
          end
          
          return self.shuffle.first # If zip doesn't return for some reason...
        else
          if options[:unique]
            randomize(options[:weights])[0...options[:count]]
          else
            pool = randomize(options[:weights])
            ::Array.new(options[:count]) { pool.random }
          end
        end
      end
      
      # Return a randomized permutation of the array, optionally based on
      # weights, as in Grunt::Extensions::Array#random.
      def randomize(weights = nil)
        return randomize(map { |o| yield o }) if block_given?
        return randomize(map { |o| o.send(weights) }) if weights.is_a?(Symbol)
        
        weights = weights.nil? ? ::Array.new(length, 1.0) : weights.dup
        
        list, result = self.dup.to_a, []
        until list.empty?
          result << list.random(:count => 1, :weights => weights)
          weights.delete_at(list.index(result.last))
          list.delete result.last
        end
        
        result
      end
    end # Array
  end # Extensions
end

class Array
  include Grunt::Extensions::Array
end
