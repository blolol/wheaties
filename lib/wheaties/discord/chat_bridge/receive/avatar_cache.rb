module Wheaties
  module Discord
    module ChatBridge
      module Receive
        class AvatarCache
          ALL_SERVER_MEMBERS_TTL = 1.hour
          AVATAR_URL_TEMPLATE = 'https://cdn.discordapp.com/avatars/%{user_id}/%{avatar_hash}.png'.freeze
          SERVER_MEMBER_LIMIT_PER_FETCH = 1000

          def initialize
            @cache = Hash.new do |cache, username|
              @cache[username] = lookup(username)
            end
          end

          def avatar_url_for_username(username)
            @cache[username]
          end

          private

          def all_server_members
            if @all_server_members.nil? || all_server_members_expired?
              @all_server_members = fetch_all_server_members
            end

            @all_server_members
          end

          def all_server_members_expired?
            @all_server_members_expires_at && Time.now > @all_server_members_expires_at
          end

          def fetch_all_server_members
            response = Discordrb::API::Server.resolve_members(Wheaties.platform.authorization_header,
              Wheaties.platform.server_id, SERVER_MEMBER_LIMIT_PER_FETCH)
            @all_server_members_expires_at = Time.now + ALL_SERVER_MEMBERS_TTL
            JSON.parse(response)
          end

          def lookup(username)
            username = username.strip

            matching_user = all_server_members.find do |user|
              display_name = user['nick'] || user.dig('user', 'global_name') ||
                user.dig('user', 'username')
              username.casecmp?(display_name.strip)
            end

            if matching_user
              user_id = matching_user.dig('user', 'id')
              avatar_hash = matching_user['avatar'] || matching_user.dig('user', 'avatar')
              url_for(user_id: user_id, avatar_hash: avatar_hash)
            end
          end

          def url_for(user_id:, avatar_hash:)
            return if user_id.blank? || avatar_hash.blank?
            substitutions = { avatar_hash: avatar_hash, user_id: user_id }
            AVATAR_URL_TEMPLATE % substitutions
          end
        end
      end
    end
  end
end
