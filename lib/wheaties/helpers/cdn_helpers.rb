module Wheaties
  module CdnHelpers
    private

    def cdn
      @cdn ||= CdnClient.new
    end

    class CdnClient
      def initialize
        @bucket = ENV.fetch('WHEATIES_CDN_BUCKET')
        @s3 = Aws::S3::Client.new
      end

      def put(key, data, content_type: :detect, metadata: {})
        object = Aws::S3::Object.new(@bucket, key)
        normalizer = DataNormalizer.new(data)
        content_type = normalizer.content_type if content_type == :detect
      end
    end

    class DataNormalizer
      attr_reader :content_type, :data_stream

      def initialize(data)
        @data = data
        normalize!
      end

      private

      def data_url?(scanner)
        scanner.scan_until(/data:(?<mime>.*?)?(?<base64>;base64)?,/)
      end

      def normalize!
        if @data.is_a?(String)
          normalize_string(@data)
        elsif @data.is_a?(StringIO)
          normalize_string(@data.read)
        elsif @data.respond_to?(:readpartial) || @data.respond_to?(:read)
          # TODO Detect content type of IO-like streams
        end
      end

      def normalize_string(data)
        scanner = StringScanner.new(data)

        if data_url?(scanner)
          @content_type = scanner.named_captures['mime'].presence || 'text/plain;charset=US-ASCII'

          decoded_data = scanner.rest
          decoded_data = Base64.decode64(decoded_data) if scanner.named_captures['base64']
          @data_stream = StringIO.new(decoded_data)
        else
          @content_type = "text/plain;charset=#{data.encoding.name}"
          @data_stream = StringIO.new(data)
        end
      end
    end
  end
end
