FROM ruby:2.5.1-alpine3.7

RUN apk add --no-cache build-base tzdata

# Throw error if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without=test

COPY bin ./bin/
COPY config ./config/
COPY lib ./lib/

ENV LANG C.UTF-8
CMD ["./bin/wheaties"]
