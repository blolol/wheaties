module Wheaties
  module ChatBridge
    class ChatEventChannel
      CHANNEL_MAPPINGS_COMMAND_NAME = 'chat_bridge_channels'.freeze

      def initialize(origin_server, origin_channel_attributes)
        @origin_server = origin_server
        @origin_channel_attributes = origin_channel_attributes
      end

      def mapping
        @mapping ||= find_mapping || mapping_not_found!
      end

      def name(platform:)
        mapping.dig(platform, 'name')
      end

      def on(platform)
        mapping[platform]
      end

      private

      attr_reader :origin_channel_attributes, :origin_server

      def find_by_matching_channel_id
        return unless matchable_by_id?

        mappings.find do |label, mapping|
          mapping.dig(origin_server_platform, 'id') == origin_channel_id
        end&.last
      end

      def find_by_matching_channel_name
        mappings.find do |label, mapping|
          mapping.dig(origin_server_platform, 'name') == origin_channel_name
        end&.last
      end

      def find_by_matching_label
        mappings.find do |label, mapping|
          label == origin_channel_name
        end&.last
      end

      def find_mapping
        case origin_server_platform
        when 'discord'
          find_by_matching_channel_id
        when 'irc'
          find_by_matching_channel_name
        else
          find_by_matching_label
        end
      end

      def mapping_not_found!
        raise ChannelMappingNotFoundError, "Couldn't find a chat bridge channel mapping for the " \
          "#{origin_server_platform} channel #{origin_channel_attributes.inspect}"
      end

      def mappings
        @mappings ||= YAML.safe_load(Command.find_by_name(CHANNEL_MAPPINGS_COMMAND_NAME).body)
      rescue Wheaties::CommandNotFoundError
        raise "Couldn't load the #{CHANNEL_MAPPINGS_COMMAND_NAME} command"
      end

      def matchable_by_id?
        origin_channel_id.present?
      end

      def origin_channel_name
        origin_channel_attributes['name']
      end

      def origin_channel_id
        origin_channel_attributes['id']
      end

      def origin_server_platform
        origin_server.platform.to_s
      end
    end
  end
end
