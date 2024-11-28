module Wheaties
  module Irc
    module ChatBridge
      class StreamEntry
        def initialize(type:, event:, content:)
          @type = type
          @event = event
          @content = content
          @timestamp = Time.now(in: 'UTC')
        end

        def publish
          logger.debug("Publishing chat bridge stream entry to #{key} => #{fields.inspect}")
          redis.xadd(key, fields)
        end

        private

        attr_reader :content, :event, :timestamp, :type

        def channel_name
          event.channel? ? event.channel.name : event.user.nick
        end

        def channel_type
          event.channel? ? 'channel' : 'dm'
        end

        def fields
          @fields ||= {
            type: payload[:type],
            timestamp: payload[:timestamp],
            :'server.name' => payload.dig(:server, :name),
            :'channel.name' => payload.dig(:channel, :name),
            payload: JSON.dump(payload)
          }
        end

        def key
          "#{key_prefix}:chat:events"
        end

        def key_prefix
          case Wheaties.env
          when 'development' then 'dev'
          when 'staging' then 'stg'
          when 'production' then 'prd'
          else
            raise "Unknown Wheaties environment name: #{Wheaties.env.inspect}"
          end
        end

        def logger
          Wheaties.logger
        end

        def payload
          @payload ||= {
            version: 1,
            type: type,
            timestamp: timestamp.iso8601,
            server: {
              platform: 'irc',
              name: ENV['IRC_SERVER']
            },
            channel: {
              name: channel_name,
              type: channel_type
            },
            user: {
              name: event.user.nick,
              host: event.user.host,
              user: event.user.user,
              realname: event.user.realname,
              authname: event.user.authname
            },
            content: content
          }
        end

        def redis
          Wheaties.redis
        end
      end
    end
  end
end
