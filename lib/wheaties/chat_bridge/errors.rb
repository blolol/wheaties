module Wheaties
  module ChatBridge
    class Error < ::StandardError; end
    class ChannelMappingNotFoundError < Error; end
  end
end
