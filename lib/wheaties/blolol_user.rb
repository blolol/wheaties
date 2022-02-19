module Wheaties
  class BlololUser
    attr_reader :relay_label

    def initialize(cinch_user)
      @cinch_user = cinch_user
    end

    def [](key)
      if response.ok?
        response['user'][key]
      end
    end

    def aliases
      self['aliases'] || []
    end

    def bot?
      roles.include?('bot')
    end

    def chat_username
      self['chat_username']
    end

    def id
      self['id']
    end

    def latitude
      self['latitude']
    end

    def location
      self['location']
    end

    def longitude
      self['longitude']
    end

    def recognized?
      response.ok?
    end

    def relayed?
      cinch_user_relayed?
    end

    def relayed_label
      if relayed?
        relayed_nick_parts.last
      end
    end

    def relayed_nick
      if relayed?
        relayed_nick_parts.first
      end
    end

    def roles
      self['roles'] || []
    end

    def time_zone
      self['time_zone']
    end

    def username
      self['username']
    end

    private

    attr_reader :cinch_user

    def blolol_api_base_url
      ENV.fetch('BLOLOL_API_BASE_URL', 'https://api.blolol.com')
    end

    def blolol_api_credentials
      "key=#{blolol_api_key} secret=#{blolol_api_secret}"
    end

    def blolol_api_key
      ENV['BLOLOL_API_KEY']
    end

    def blolol_api_secret
      ENV['BLOLOL_API_SECRET']
    end

    def cinch_user_relayed?
      # Blolol's Ergo config reserves "/" for RELAYMSG nicknames.
      cinch_user.nick.include?('/')
    end

    # Split a RELAYMSG nick (e.g. "Doolan/Discord") on the first "/". The part before the
    # first "/" is the nickname, and the part after the first "/" is the relay label. The
    # relay label usually provides a clue as to where the RELAYMSG came from.
    def relayed_nick_parts
      @relayed_nick_parts ||= cinch_user.nick.split('/', 2)
    end

    def response
      @response ||= HTTParty.get(request_url, headers: request_headers)
    end

    def request_headers
      {
        'Authorization' => blolol_api_credentials,
        'Accept' => 'application/json'
      }
    end

    def request_url
      "#{blolol_api_base_url}/v1/users/#{URI.escape(request_username)}"
    end

    def request_username
      if cinch_user.authed?
        cinch_user.authname
      elsif cinch_user_relayed?
        relayed_nick
      end
    end
  end
end
