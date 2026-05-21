module Wheaties
  module CdnHelpers
    private

    def cdn
      @cdn ||= CdnClient.new
    end

    class CdnClient
      attr_reader :base_url, :s3

      def initialize
        @base_url = ENV.fetch('WHEATIES_CDN_BASE_URL')
        @bucket = ENV.fetch('WHEATIES_CDN_BUCKET')
        @s3 = Aws::S3::Client.new
      end

      def delete(key)
        s3.delete_object(bucket: @bucket, key:)
      end

      def exists?(key)
        Aws::S3::Object.new(@bucket, key).exists?
      end

      def get(key)
        s3.get_object(bucket: @bucket, key:)
      end

      def put(key, data, content_type: :detect, metadata: {})
        normalizer = DataNormalizer.new(data)
        content_type = normalizer.content_type if content_type == :detect
        s3.put_object(bucket: @bucket, key:, body: normalizer.data_stream, content_type:, metadata:)
      end

      def url(key)
        "#{base_url}/#{key}"
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
          normalize_stream(@data)
        end
      end

      def normalize_stream(stream)
        filename = @data.respond_to?(:path) ? File.basename(@data.path) : nil
        @content_type = Marcel::MimeType.for(@data, name: filename)
        @data.rewind if @data.respond_to?(:rewind)
        @data_stream = @data
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
