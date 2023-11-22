FROM ruby:3.1.3

RUN apt-get update \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -  \
  && apt-get install -y --no-install-recommends build-essential libpq-dev nodejs \
  && apt-get clean \
  && npm install --global yarn \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /fcs_acquirer

ENV APP_ROOT /fcs_acquirer
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT/Gemfile
COPY Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install

COPY . .

ENV NODE_OPTIONS --openssl-legacy-provider

ENTRYPOINT ["bin/docker-entrypoint"]
