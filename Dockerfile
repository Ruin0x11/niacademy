FROM elixir:1.10.3-alpine as build

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python

ARG SECRET_KEY_BASE
ARG DATABASE_URL
ARG IMAGES_PATH
ARG GLOBAL_USER
ARG PASSWORD
ARG LETSENCRYPT_HOST
ARG PORT

ENV SECRET_KEY_BASE=$SECRET_KEY_BASE
ENV DATABASE_URL=$DATABASE_URL
ENV IMAGES_PATH=$IMAGES_PATH
ENV GLOBAL_USER=$GLOBAL_USER
ENV PASSWORD=$PASSWORD
ENV LETSENCRYPT_HOST=$LETSENCRYPT_HOST
ENV PORT=$PORT

RUN mkdir /app
WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
# at this point we should copy the rel directory but
# we are not using it so we can omit it
# COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.9 AS app

# install runtime dependencies
RUN apk add --update bash openssl postgresql-client curl

ARG UNAME=nia
ARG UID=1000

RUN adduser -S -D -u $UID $UNAME

EXPOSE 4000
ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app

# copy release to app container
COPY --from=build /app/_build/prod/rel/niacademy .
COPY entrypoint.sh .
RUN chown -R $UNAME: /app
USER $UNAME

ENV HOME=/app
CMD ["bash", "/app/entrypoint.sh"]
