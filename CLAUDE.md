# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Wheaties is an IRC chat bot (built on a [Cinch](https://github.com/blolol/cinch) fork) whose commands are stored in MongoDB and edited at runtime via chat or a separate web app. README.md has the full list of environment variables (`.env.example` is the template).

## Commands

```sh
bundle install
bin/wheaties                      # Run the bot (needs MongoDB + Redis, and env from .env)
bin/console                       # Pry REPL with the Wheaties environment loaded
bundle exec rspec                 # Run all specs
bundle exec rspec spec/harby/parser_spec.rb          # One file
bundle exec rspec spec/harby/parser_spec.rb:12       # One example
docker-compose up                 # MongoDB, Redis and Wheaties
bundle exec rake docker:build     # Build/tag Docker image (also docker:push, docker:run)
```

## Architecture

**Boot.** `bin/wheaties` does `Bundler.require(:default, :commands)` (the `commands` gem group holds gems that user-written Ruby commands may use), builds the `Cinch::Bot` with `CommandsPlugin` and `RelayPlugin`, then `Wheaties.configure` (`lib/wheaties/boot.rb`) sets up logger, Bugsnag, Redis, Mongoid, ruby_llm, and loads `config/environments/<WHEATIES_ENV>.rb`. All files are loaded via the explicit require list in `lib/wheaties.rb` — new files must be added there.

**Message flow.** `CommandsPlugin` listens to IRC events (message, join, nick, topic, ctcp, connect, leaving). Each maps to an `Events::*Event` class. A message matching the command prefix (`.`, or `!` for debug) becomes a `CommandInvocation`; messages matching the assignment pattern go through `AssignmentEvent`. Matterbridge-relayed messages (`[source] <nick> text`) are also recognized. `RelayPlugin` polls SQS and delivers messages to IRC.

**Parsing (`lib/harby`).** Treetop grammars (`lib/harby/grammar/*.treetop`) parse command invocation syntax: arguments, nested subcommands, lists, regexes, numerics, strings. `Wheaties::ParserFactory`/`ParserDelegate` wrap this. Subcommands are evaluated via `SubcommandInvocation`.

**Commands.** `Command` is a Mongoid document (top-level class, not namespaced) with STI subclasses in `lib/wheaties/commands/`: `RubyCommand` (body is Ruby `Kernel.eval`'d inside an `InvocationEnvironment`), `PlainTextCommand`, `RandomLineCommand`, `YamlCommand`, and `BuiltInCommand`. Lookup is by name via `CommandCache`, falling back to regex-enabled commands (`FIND_COMMANDS_BY_REGEX`). `EventCommandCache` caches commands configured to run on IRC events. Each save creates an embedded `Version`.

**Execution environment.** `InvocationEnvironment` is the eval context for Ruby commands; it mixes in the modules in `lib/wheaties/helpers/*` (CDN, formatting, storage via Redis/Mongo, messaging, logging, etc.), which form the API available to user-written commands. Built-in command names are listed in `BUILT_IN_COMMANDS`. Results are wrapped in `*InvocationResult` classes (`RubyInvocationResult`, `ErrorResult`, `SyntaxErrorResult`, `CommandNotFoundResult`, ...).

**Cinch extensions** live in `lib/wheaties/cinch_ext/`. Errors are reported to Bugsnag via `BugsnagNotifier`.

## Notes

- Ruby 3.4.9 (see `Gemfile`/`.ruby-version`); rspec is pinned to ~> 3.7.
- `Wheaties.logger` is used for Mongo/Mongoid/Bugsnag logging, but not for ruby_llm (see recent commits).
- Test coverage is minimal (`spec/harby/parser_spec.rb`, helper and weighted_random specs).
