#!/bin/bash

set -e

revision=$(git rev-parse HEAD)

_main () {
  make prod-image

  _log_into_registry
  _push_to_registry
}

_log_into_registry () { heroku auth:token 2> /dev/null | docker login --username=_ --password-stdin registry.heroku.com 2> /dev/null; }

_push_to_registry () {
  for app_name in $APP_NAMES
  do
    registry_path="registry.heroku.com/$app_name/app:$revision"
    echo "Pushing to $app_name registry ..."

    docker tag "$CIRCLE_PROJECT_REPONAME" "$registry_path"
    docker push "$registry_path" &
  done
  wait && echo "done"
}

_main
