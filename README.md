# Wheaties

Wheaties is Blolol's resident chat bot. Users program him on the fly using a combination of chat commands and [his web interface](https://github.com/blolol/wheaties-web). Commands are written in Ruby. Wheaties: botfast of champions!

## Table of Contents

* [Installation](#installation)
  * [Using Docker](#using-docker)
  * [From Source](#from-source)
  * [Configuration](#configuration)
  * [Message Relay](#message-relay)
* [Releasing](#releasing)
* [License](#license)

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
| `DEBUG_PREFIX` | Optional | Prefix for triggering commands with debug logging (default: "!") |
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
| `WHEATIES_CDN_BASE_URL` | **Required** | The base URL to Wheaties' CDN, used by `Wheaties::CdnHelpers` |
| `WHEATIES_CDN_BUCKET` | **Required** | The S3 bucket name used by `Wheaties::CdnHelpers` |
| `WHEATIES_ENV` | Optional | The environment to use (`development`, `staging`, `production`) |

### Message Relay

Wheaties is capable of relaying messages from an Amazon SQS queue to IRC. Given a queue with messages like this:

```json
{
  "event": {
    "type": "message",
    "from": "Wheaties",
    "to": "#example",
    "text": "Hello world!"
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

## Releasing

Wheaties runs on [Northflank](https://northflank.com), in the `wheaties` project. Pushing to `main` builds the bot once and deploys it to staging (`stg-bot`). To release, a person promotes the exact image running on staging to production (`prd-bot`). Production never builds anything itself.

The Northflank resources are defined in [`blolol-infrastructure/northflank/wheaties.json`](https://github.com/blolol/blolol-infrastructure/blob/main/northflank/wheaties.json).

### 1. Tag a release

From `main`, with your changes merged and committed, run:

```sh
bundle exec rake release:tag
```

The task:

1. Prints the current `Wheaties::VERSION` and prompts for the new version. Press Enter to accept the default, which is the current version with the patch number bumped (e.g. `2.12.4` becomes `2.12.5`).
2. Updates `Wheaties::VERSION` in `lib/wheaties/version.rb`.
3. Stages that file. If anything else is already staged, the task lists those files and offers to cancel. If you continue, only the version file goes into the release commit.
4. Commits the change as `Wheaties X.Y.Z`.
5. Tags the commit as `vX.Y.Z`.
6. Offers to push the current branch and the new tag to `origin`.

### 2. Promote to production

Once the tagged commit has deployed to staging and looks good there, run:

```sh
bundle exec rake release:promote
```

To wait for staging first, run `bundle exec rake release:wait`. It waits until `build-bot` has built `HEAD` (or the commit given as `release:wait[ref]`) and `stg-bot` has finished rolling it out. It fails if the commit isn't on `origin/main`, the build or rollout fails, or 20 minutes pass (set `TIMEOUT` in seconds to change this). Chain the tasks to release in one go:

```sh
bundle exec rake release:tag release:wait release:promote
```

You'll need the [Northflank CLI](https://northflank.com/docs/v1/api/use-the-cli), logged in to the `blolol` team. The task:

1. Reads the commit deployed to `stg-bot` and the one deployed to `prd-bot`, and lists the commits between them.
2. Asks you to confirm.
3. Runs the `promote-bot` workflow in Northflank's `production` environment. The workflow takes a snapshot of `prd-mongodb`, waits for it to finish, and then deploys `stg-bot`'s current image to `prd-bot`.

Follow the run in Northflank under **wheaties → production → Workflows**.

### Rolling back

Northflank has no one-click rollback for a promotion. Either:

* **Revert and promote again.** Revert the bad commit on `main`, let it deploy to staging, and run `rake release:promote`.
* **Pin production to an earlier build**, if you need to roll back right away. Find the build of the commit you want under **build-bot → Builds**, then run:

  ```sh
  northflank update service deployment --projectId wheaties --serviceId prd-bot \
    --input '{"internal": {"id": "build-bot", "branch": "main", "buildSHA": "<full 40-character commit SHA>"}}'
  ```

  The next promotion replaces this as usual.

If you also need the old data, restore `prd-mongodb` from the snapshot the promotion took. Find it under **prd-mongodb → Backups**.

## License

Copyright (c) 2026 Ross Paffett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
