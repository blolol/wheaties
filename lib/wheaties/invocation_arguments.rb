module Wheaties
  # A subclass of Array that has some convenience features for accessing and manipulating
  # Wheaties command invocation arguments.
  class InvocationArguments < ::Array
    # The original command argument string as it was sent by the user who invoked the
    # command, before it was parsed into the individual arguments stored in this
    # InvocationArguments instance.
    attr_reader :unparsed

    delegate :unstringify, to: :stringified

    def initialize(parsed_arguments = [], unparsed_arguments = '')
      @unparsed = unparsed_arguments
      super(parsed_arguments || [])
    end

    # Syntactic sugar for Ruby's OptionParser. The block provided will be passed to
    # OptionParser.new. Supplying the optional `into` argument will cause OptionParser
    # to call #[]= on the supplied object with parsed option values.
    #
    # Returns an instance of InvocationArguments containing any remaining args.
    def parse_options(into: nil, &block)
      OptionParser.new(&block).parse!(stringified, into: into)
      remaining = stringified.remaining_from(self)
      self.class.new(remaining, unparsed)
    end

    private

    def stringified
      @stringified ||= StringifiedArray.new(self)
    end

    # An Array that calls #to_s on each of its initial elements, and stores a map of
    # the stringified version to the original element. This is required because Ruby's
    # OptionParser throws a TypeError if the "argv" supplied to it contains elements
    # that are not Strings.
    #
    # So, in order to preserve access to the original, un-stringified command arguments,
    # while also allowing OptionParser to destructively parse option switches and their
    # values out of those command arguments, we use this class to keep track, to the best
    # of our ability, of which stringified argument maps to which original argument.
    #
    # After this StringifiedArray is modified by OptionParser#parse!, the original
    # InvocationArguments can be passed to #remaining_from to return the arguments that
    # were not removed as part of option parsing.
    class StringifiedArray < ::Array
      def initialize(array)
        @hashes = {}

        stringified_array = array.map do |element|
          stringified = element.to_s
          @hashes[stringified] = element
          stringified
        end

        super(stringified_array)
      end

      def remaining_from(other_array)
        other_array & (@hashes.fetch_values(*self))
      end

      # For the given stringified argument, return the original object.
      def unstringify(stringified)
        @hashes[stringified]
      end
    end
  end
end
