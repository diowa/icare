FROM ruby:2.7.1-alpine

RUN apk add --no-cache --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgis \
  postgresql-dev \
  tzdata \
  yarn

ENV APP_DIR /icare

EXPOSE 3000

WORKDIR $APP_DIR

# Create application user and add permissions
RUN addgroup icare && \
    adduser -D icare -G icare && \
    chown -R icare:icare $APP_DIR && \
    chmod -R 755 $APP_DIR

# Switch to application user
USER icare

RUN mkdir -p log
RUN mkdir -p tmp/pids

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

RUN mkdir -p log
RUN mkdir -p tmp/pids

RUN gem install bundler --version "2.1.2"

# Copy command always runs as root
COPY --chown=icare:icare Gemfile Gemfile
COPY --chown=icare:icare Gemfile.lock Gemfile.lock

RUN echo $RAILS_ENV
RUN \
  if [ "$RAILS_ENV" = "development" ] || [ "$RAILS_ENV" = "test" ]; then \
    bundle install --retry 10; \
  else \
    bundle config set deployment 'true' && bundle --retry 10; \
  fi

COPY --chown=icare:icare package.json package.json
COPY --chown=icare:icare yarn.lock yarn.lock

RUN yarn

COPY --chown=icare:icare app ./app
COPY --chown=icare:icare bin ./bin
COPY --chown=icare:icare config ./config
COPY --chown=icare:icare db ./db
COPY --chown=icare:icare lib ./lib
COPY --chown=icare:icare public ./public
COPY --chown=icare:icare spec ./spec
COPY --chown=icare:icare .browserslistrc .
COPY --chown=icare:icare .postcssrc.yml .
COPY --chown=icare:icare babel.config.js .
COPY --chown=icare:icare config.ru .
COPY --chown=icare:icare postcss.config.js .
COPY --chown=icare:icare Rakefile .

RUN SECRET_KEY_BASE=dummy DATABASE_URL=postgis:dummy bundle exec rails assets:precompile

COPY --chown=icare:icare docker/icare/docker-entrypoint.sh ./bin
RUN chmod +x ./bin/docker-entrypoint.sh

ENTRYPOINT ["/icare/bin/docker-entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
