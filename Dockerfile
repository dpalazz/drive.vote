FROM ruby:2.5.1-alpine3.7

RUN apk update
RUN apk add \
  bash \
  build-base \
  git \
  nodejs \
  python3 \
  postgresql-dev \
  postgresql-client \
  tzdata \
  yarn \
  && rm -rf /var/cache/apk/*

# RUN gem install bundler

# First copy the bundle files and install gems to aid caching of this layer
WORKDIR /tmp
COPY Gemfile* /tmp/
RUN bundle install

ENV app /dtv
RUN mkdir $app
WORKDIR $app
ADD . $app

EXPOSE 3000