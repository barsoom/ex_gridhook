FROM elixir:1.9.2-alpine AS base

RUN apk add --no-cache bash git openssh

RUN set -ex \
  && apk add --no-cache shadow \
  && groupadd -g 501 deploy \
  && useradd -r -u 501 -g deploy deploy \
  && apk del shadow \
  && mkdir /home/deploy \
  && chown deploy:deploy /home/deploy

RUN set -ex \
  && mkdir -p /home/deploy/.ssh \
  && apk --no-cache --virtual .ssh-keyscan add openssh \
  && ssh-keyscan github.com >> /home/deploy/.ssh/known_hosts \
  && apk del .ssh-keyscan

ENV MIX_HOME=/app_deps/mix \
  HEX_HOME=/app_deps/hex \
  DEPS_PATH=/app_deps/deps \
  BUILD_PATH=/app_deps/build

RUN mkdir -p /app && chown deploy:deploy /app
RUN mkdir -p /app_deps && chown -R deploy:deploy /app_deps
USER deploy

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# Make postgres commands available
USER root
COPY --from=postgres:9.6.15-alpine /usr/local /usr/local
RUN apk add openssl libedit --no-cache

# If you see errors like `Error loading shared library libssl.so.1.0.0: No such file or directory (needed by /usr/local/lib/libpq.so.5)` the base image used to build "postgres:x.x-alpine" differs from the base image used to build "elixir:x.x.x-alpine". This can most likely be fixed by using the latest versions of both.
#
# We install postgres this way because it's convenient to re-use the already compiled version and not have to maintain compilation and installation scripts for postgres.
RUN psql --version | grep "psql (PostgreSQL) 9.6.15"

# Release ---------------------------------------------------------------------
FROM base AS release

USER deploy

ENV MIX_ENV=prod

# First build a later of cached deps so that small changes later does not require us to rebuild the entire deps layer.
COPY --chown=deploy:deploy .docker/cache/mix.lock .docker/cache/mix.exs ./
RUN mix deps.get
RUN mix compile

# Then update with the latest deps.
COPY mix.lock mix.exs ./
RUN mix deps.get
RUN mix compile

ADD . .
RUN mix compile

# https://github.com/phoenixframework/phoenix/issues/2690
CMD ["mix", "do", "deps.loadpaths", "--no-deps-check,", "phx.server"]

#ARG REVISION="unknown"
#ENV REVISION=$REVISION

#FROM base AS test

# TODO: get envs set up for running the prod image, needs to load dynamically, not at compile time
# TODO: set up dev server with mounted filesystem so code can reload
# TODO: set up autotest