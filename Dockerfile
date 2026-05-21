FROM ruby:3.4.9

# Install additional packages:
#   * Git is required to fetch Ruby gems from Git repositories
#   * tzdata is used by Wheaties commands
#   * yt-dlp is used by Wheaties commands
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'deb http://deb.debian.org/debian trixie-backports main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git tzdata && \
    apt-get -t trixie-backports install -y yt-dlp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Throw error if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without=test

COPY bin ./bin/
COPY config ./config/
COPY lib ./lib/

ENV LANG=C.UTF-8
CMD ["./bin/wheaties"]
