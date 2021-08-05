FROM elixir:latest 

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY lib lib

COPY test test

RUN mix do compile, release
RUN mkdir /app/g

EXPOSE 80

ENTRYPOINT ["/app/_build/prod/rel/gitserv/bin/gitserv", "start"]
