module Grunt
  module Extensions
    module Hash
      # Select one or more random elements from the hash, optionally based on
      # weights. Basic usage is the same as Grunt::Extensions::Array#random.
      #
      # By default, random will return an array of random hash values. Supply
      # <tt>:of => :keys</tt> to receive an array of random hash keys instead.
      # Alternatively, <tt>:as => :hash</tt> will return a hash.
      def random(*args)
        options = args.find { |o| o.is_a?(Hash) } || {}
        options.reverse_merge! :as => :array, :of => :values
        
        pool = keys.random(*args)
        if options[:as] == :hash
          pool = [pool] unless pool.is_a?(Array)
          select { |key, value| pool.include?(key) }.inject({}) do |hash, pair|
            hash[pair[0]] = pair[1]; hash
          end
        else
          options[:of] == :keys ? pool : values_at(*pool)
        end
      end
    end # Hash
  end # Extensions
end

class Hash
  include Grunt::Extensions::Hash
end
