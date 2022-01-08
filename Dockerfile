# Base image with ruby + buildtime dependencies
FROM ruby:3.1.0-alpine as ruby_base

RUN apk add --update --no-cache \
  # build toolchain for C extension gems
  build-base \
  # timezone data for rails
  tzdata \
  # required to build mysql2 gem
  mysql-dev \
  # database client for mysql
  mysql-client

# Gem cache layer
FROM ruby_base as gems_cache

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

RUN mkdir /app
WORKDIR /app

RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'
RUN bundle config set path './vendor/bundle'

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install && rm -rf /root/.bundle/cache

# Rails environment layer
FROM ruby_base as rails_environment

ARG DATABASE_URL
ARG RAILS_ENV=production
ARG RAILS_LOG_TO_STDOUT=enabled
ARG RAILS_MASTER_KEY
ARG RAILS_SERVE_STATIC_FILES
ARG REDIS_URL

ENV DATABASE_URL=${DATABASE_URL}
ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_LOG_TO_STDOUT=${RAILS_LOG_TO_STDOUT}
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV RAILS_SERVE_STATIC_FILES=${RAILS_SERVE_STATIC_FILES}
ENV REDIS_URL=${REDIS_URL}

WORKDIR /app
COPY . /app

COPY --from=gems_cache /usr/local/bundle /usr/local/bundle
COPY --from=gems_cache /app/vendor/bundle /app/vendor/bundle

RUN bundle config --local path vendor/bundle

# WEBSERVER BUILD
FROM rails_environment as rails_webserver

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# SIDEKIQ BUILD
FROM rails_environment as sidekiq_process

CMD ["bundle", "exec", "sidekiq"]
