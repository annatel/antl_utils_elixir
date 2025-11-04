VERSION 0.6

elixir-base:
    FROM --platform=$BUILDPLATFORM elixir:1.18.4-otp-27-alpine
    WORKDIR /app
    RUN apk add --no-progress --update openssh-client git build-base
    RUN mix local.rebar --force && mix local.hex --force

deps:
    ARG MIX_ENV
    FROM +elixir-base
    ENV MIX_ENV="$MIX_ENV"
    COPY --dir config .
    COPY mix.exs .
    COPY mix.lock .
    RUN mix deps.get --only "$MIX_ENV"
    RUN mix deps.compile

lint:
    FROM --build-arg MIX_ENV="dev" +deps
    COPY --dir lib .
    COPY .formatter.exs .
    RUN mix deps.unlock --check-unused
    RUN mix format --check-formatted
    RUN mix compile --warnings-as-errors

test:
    FROM --build-arg MIX_ENV="test" +deps
    COPY --dir lib test .
    RUN mix test --warnings-as-errors

check-tag:
    ARG TAG
    FROM +elixir-base
    COPY mix.exs .
    ARG APP_VERSION=$(mix app.version)
    IF [ ! -z $TAG ] && [ ! $TAG == $APP_VERSION ]
        RUN echo "TAG '$TAG' has to be equal to APP_VERSION '$APP_VERSION'" && false
    END
