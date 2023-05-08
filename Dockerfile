ARG ERLANG_VERSION
ARG ELIXIR_VERSION
ARG ALPINE_VERSION

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION} AS base
 
# Install tooling
RUN apk add --no-cache bash tini git curl

FROM base AS build

# Setting up env
ARG MIX_ENV
ENV MIX_ENV=${MIX_ENV}
ENV MIX_HOME=/opt/app/mix
ENV CACHE_VERSION=v1

# Switch to working directory
WORKDIR /opt/app

# Install mix dependencies
RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy app and compile
COPY . .

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv/gettext priv/gettext
COPY priv/repo priv/repo

# Generate revision file
ARG REVISION
RUN echo ${REVISION} > /opt/app/built_from_revision

# https://github.com/krallin/tini for better signal handling.
ENTRYPOINT ["/sbin/tini", "-s", "--"]
