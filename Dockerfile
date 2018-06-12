# vim:set ft=dockerfile:
FROM ruby:2.5.1-alpine3.7
LABEL maintainer="fcduythien@gmail.com"

ENV PROJECT_DIR=/app
ENV PASSENGER_VERSION=5.2.2

RUN if ! test -d $PROJECT_DIR; then mkdir -p $PROJECT_DIR ; fi && \
  if ! test -d "$PROJECT_DIR/tmp/pids"; then mkdir -p "$PROJECT_DIR/tmp/pids"; fi && \
  if ! test -d "$PROJECT_DIR/log"; then mkdir -p "$PROJECT_DIR/log"; fi
RUN set -ex \
    && apk --update add --virtual .ruby-builddeps \
      autoconf \
      bison \
      bzip2 \
      bzip2-dev \
      ca-certificates \
      coreutils \
      curl \
      gcc \
      gdbm-dev \
      glib-dev \
      libc-dev \
      libffi-dev \
      libxml2 \
      libxml2-dev \
      libxslt-dev \
      make \
      ncurses-dev \
      procps \
      readline-dev \
      ruby \
      yaml-dev \
      zlib-dev \
      g++ \
      postgresql-dev \
      libgcrypt-dev \
      ca-certificates \
      curl \
      libffi-dev \
      yaml-dev \
      procps \
      zlib-dev \
      linux-headers \
      git \
      nodejs \
      tzdata

RUN apk --no-cache add --virtual passenger-dependencies \
    curl-dev pcre-dev ruby-dev \
    && gem install -v "$PASSENGER_VERSION" passenger --no-rdoc --no-ri \
    && echo "#undef LIBC_HAS_BACKTRACE_FUNC" > /usr/include/execinfo.h \
    && passenger-config install-standalone-runtime --auto \
    && passenger-config build-native-support \
    && apk del --purge passenger-dependencies


RUN bundle config git.allow_insecure true
# Temporarily set the working directory to where they are. 
COPY Gemfile Gemfile.lock "$PROJECT_DIR/"
RUN cd $PROJECT_DIR && bundle install --quiet --jobs 2

WORKDIR $PROJECT_DIR

COPY docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
	&& rm -rf "$PROJECT_DIR/docker" && rm -rf .git rm -rf /var/cache/apk/*

ADD . ./

ENTRYPOINT ["docker-entrypoint.sh"]
VOLUME ["$PROJECT_DIR", "$PROJECT_DIR/log", "$PROJECT_DIR/tmp"]
EXPOSE 80
CMD ["start"]

