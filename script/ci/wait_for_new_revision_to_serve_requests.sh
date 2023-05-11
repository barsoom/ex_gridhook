#!/bin/bash

set -e

app_name=$1
revision=$2
url="https://$app_name.herokuapp.com/revision"

printf 'Waiting for the app to start serving requests using %s ' "$revision"

while true; do
  current_revision=$(curl --silent "$url")

  if [[ "$revision" = "$current_revision" ]]; then
    echo " Done"

    break
  fi

  printf '.'
  sleep 1
done
