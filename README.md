# Wheaties

Wheaties is Blolol's resident chat bot. Users program him on the fly using a combination of chat commands and [his web interface](https://github.com/blolol/wheaties.blolol.com). Commands are written in Ruby. Wheaties: botfast of champions!

## Installation

To install Wheaties, you'll need Ruby and [Bundler](https://bundler.io). First, install the Ruby gem dependencies.

```sh
bundle install
```

Configure Wheaties with environment variables. See `.env.example` for examples.

| Name | Required? | Description |
|------|-----------|-------------|
| `BUGSNAG_API_KEY` | Required | API key for reporting errors to [Bugsnag](https://www.bugsnag.com) |
| `IRC_CHANNELS` | Required | Comma-separated list of IRC channels to join |
| `IRC_MESSAGES_PER_SECOND` | Optional | Maximum messages per second to send to the IRC server |
| `IRC_NICK` | Required | IRC nickname |
| `IRC_PASS` | Optional | IRC server password |
| `IRC_PORT` | Required | IRC server port |
| `IRC_REALNAME` | Required | IRC real name |
| `IRC_SERVER` | Required | IRC server address |
| `IRC_SSL` | Optional | Set to `true` to connect using SSL/TLS |
| `IRC_SSL_VERIFY` | Optional | Set to `false` to skip TLS certificate verification |
| `IRC_USER` | Required | IRC server username |
| `MONGOID_ENV` | Required | The Mongoid config environment to use (`development` or `production`) |
| `WHEATIES_BASE_URL` | Required | The base URL to Wheaties' web interface |

To start Wheaties, simply run `bin/wheaties`.

```sh
bin/wheaties
```

You can also run `bin/console` to start an IRB REPL with Wheaties' environment loaded, which can be useful for interacting manually with commands.

## License

Copyright (c) 2018 Ross Paffett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
