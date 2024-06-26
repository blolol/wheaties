# Wheaties

Wheaties is Blolol's resident chat bot. Users program him on the fly using a combination of chat commands and [his web interface](https://github.com/blolol/wheaties.blolol.com). Commands are written in Ruby. Wheaties: botfast of champions!

## Installation

### Using Docker

You can run Wheaties using Docker. There's also a Docker Compose config that will run MongoDB and Redis.

To configure Wheaties, use any of Docker's methods for setting the container environment. The included Docker Compose config automatically attempts to read from a file named `docker.env`. See "[Configuration](#configuration)", below, for details about the supported environment variables.

```sh
docker build -t wheaties . # Build manually
bundle exec rake docker:build # Or use the Rake task, which automatically tags the correct version

docker run --rm -i --env-file=docker.env wheaties # Run a one-off container
bundle exec rake docker:run # Or use the Rake task to do the same thing

docker-compose up # Bring up MongoDB, Redis and Wheaties using Docker Compose
bundle exec rake docker:mongo:restore[path/to/mongo/dump] # Restore a MongoDB dump to the Compose MongoDB container
```

### From Source

To run Wheaties from source, you'll need:

* Ruby >= 3.3.1
* [Bundler](https://bundler.io)
* MongoDB >= 7.0
* Redis >= 7.2

First, install the Ruby gem dependencies using Bundler.

```sh
bundle install
```

Configure Wheaties with environment variables. See "[Configuration](#configuration)", below, for details.

```sh
cp .env.example .env
```

To start Wheaties, simply run `bin/wheaties`. He'll attempt to connect to MongoDB and Redis running on `localhost` on their default ports. You can override this behavior by setting `MONGODB_URL` and `REDIS_URL`.

```sh
bin/wheaties
```

You can also run `bin/console` to start a Pry REPL with Wheaties' environment loaded, which can be useful for interacting manually with commands.

### Configuration

Wheaties can be configured using the following environment variables.

| Name | Required? | Description |
|------|-----------|-------------|
| `AWS_ACCESS_KEY_ID` | Optional | AWS access key ID used to read from Amazon SQS |
| `AWS_SECRET_ACCESS_KEY` | Optional | AWS secret access key used to read from Amazon SQS |
| `BLOLOL_API_BASE_URL` | Optional | The base URL to Blolol's API (default: `https://api.blolol.com`) |
| `BLOLOL_API_KEY` | **Required** | Blolol API key |
| `BLOLOL_API_SECRET` | **Required** | Blolol API secret |
| `BUGSNAG_API_KEY` | **Required** | API key for reporting errors to [Bugsnag](https://www.bugsnag.com) |
| `COMMAND_PREFIX` | Optional | Prefix for triggering commands (default: ".") |
| `EVENT_COMMAND_CACHE_TTL_SECONDS` | Optional | Seconds to cache the list of commands that are configured to run automatically on certain IRC events (default: 300) |
| `FIND_COMMANDS_BY_REGEX` | Optional | Set to `true` to search for commands using regular expressions (default: true) |
| `IRC_CHANNELS` | **Required** | Comma-separated list of IRC channels to join |
| `IRC_MESSAGES_PER_SECOND` | Optional | Maximum messages per second to send to the IRC server |
| `IRC_NICK` | **Required** | IRC nickname |
| `IRC_PASS` | Optional | IRC server password |
| `IRC_PORT` | **Required** | IRC server port |
| `IRC_REALNAME` | **Required** | IRC real name |
| `IRC_SERVER` | **Required** | IRC server address |
| `IRC_SASL_PASS` | Optional | SASL authentication password |
| `IRC_SASL_USER` | Optional | SASL authentication username |
| `IRC_SSL` | Optional | Set to `true` to connect using SSL/TLS |
| `IRC_SSL_VERIFY` | Optional | Set to `false` to skip TLS certificate verification |
| `IRC_USER` | **Required** | IRC server username |
| `MATTERBRIDGE_USER` | Optional | Matterbridge bot username. If this environment variable is set, Wheaties will respond to command invocations from any user with this username, where the message matches this pattern: `[source] <nick> message` |
| `MONGODB_URL` | Optional | Mongoid connection URL |
| `REDIS_URL` | Optional | Redis connection URL |
| `RELAY_MESSAGE_CHECK_INTERVAL_SECONDS` | Optional | Long poll Amazon SQS for this many seconds (default: 10) |
| `RELAY_QUEUE_URL` | Optional | The Amazon SQS queue URL to poll for messages to relay to IRC |
| `WHEATIES_BASE_URL` | **Required** | The base URL to Wheaties' web interface |
| `WHEATIES_ENV` | Optional | The environment to use (`development`, `staging`, `production`) |

### Message Relay

Wheaties is capable of relaying messages from an Amazon SQS queue to IRC. Given a queue with messages like this:

```json
{
  "event": {
    "type": "message",
    "from": "Wheaties",
    "to": "#example",
    "message": "Hello world!"
  }
}
```

Wheaties will deliver "Hello world!" to the channel #example, if he is in that channel (or the server and channel allow messages from users not in the channel). `to` can be a channel name or a user's nickname, to deliver a private message.

To enable Wheaties' message relay, set these environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `RELAY_QUEUE_URL` (an Amazon SQS queue URL)

Your AWS credentials must be allowed to perform these actions on the SQS queue:

* `sqs:ChangeMessageVisibility`
* `sqs:DeleteMessage`
* `sqs:GetQueueAttributes`
* `sqs:ReceiveMessage`

By default, Wheaties will long poll SQS for up to 10 seconds. You can customize his poll interval by setting `RELAY_MESSAGE_CHECK_INTERVAL_SECONDS`.

## License

Copyright (c) 2024 Ross Paffett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
