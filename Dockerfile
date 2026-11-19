FROM ruby:3.4.13

# Install additional packages:
#   * Git is required to fetch Ruby gems from Git repositories
#   * libvips is used by Wheaties commands, via the ruby-vips gem
#   * tzdata is used by Wheaties commands
#   * yt-dlp is used by Wheaties commands
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'deb http://deb.debian.org/debian trixie-backports main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git libvips42 tzdata && \
    apt-get -t trixie-backports install -y yt-dlp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Throw error if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle config set without test && bundle install

COPY bin ./bin/
COPY config ./config/
COPY lib ./lib/
COPY vendor ./vendor/

ENV LANG=C.UTF-8
CMD ["./bin/wheaties"]
