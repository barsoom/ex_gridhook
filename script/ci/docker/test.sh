#!/bin/sh

cleanup() {
  errcode=$1
  docker-compose -f docker-compose.test.yml down
  exit $errcode
}

docker-compose -f docker-compose.test.yml up --no-start || exit $?
docker-compose -f docker-compose.test.yml start postgres || cleanup $?
docker-compose -f docker-compose.test.yml run --rm app mix do ecto.create, ecto.migrate || cleanup $?
docker-compose -f docker-compose.test.yml run --rm app mix test || cleanup $?

# ensure we shut down
cleanup 0
