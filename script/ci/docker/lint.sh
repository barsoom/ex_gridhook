#!/bin/sh

cleanup() {
  errcode=$1
  docker kill app > /dev/null
  exit $errcode
}

docker run -d --rm --name app ex_gridhook:test sleep infinity > /dev/null

docker exec app mix format --check-formatted || cleanup $?
docker exec app mix credo || cleanup $?

# ensure we shut down
cleanup 0
