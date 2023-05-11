#!/bin/bash
# shellcheck disable=SC2001

set -e

app_name=$1
revision=$CIRCLE_SHA1

# Deploy
_main () {
  app_name_uppercase_and_underscored=$(echo "${app_name^^}" | sed s/-/_/g)
  heroku_token=$(heroku auth:token 2> /dev/null)

  _deploy_to_heroku
  _ensure_new_revision_is_running
}

_deploy_to_heroku () {
  if _revision_is_newer_than_or_the_same_as_the_deployed_revision; then
    echo "This revision is newer than or the same as the deployed revision. Allowing deploy."
  else
    echo "The currently deployed app is running a newer revision. Skipping deploy to avoid rolling back changes."
    echo "Canceling current build."
    curl --silent --user "${CIRCLE_API_TOKEN}": -X POST "https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BUILD_NUM/cancel" 1> /dev/null
    sleep 10
    exit 1
  fi

  curl -X PATCH "https://api.heroku.com/apps/$app_name/formation" \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.heroku+json; version=3.docker-releases" \
    -H "Authorization: Bearer $heroku_token" \
    -d "$(_heroku_release_json)"

  curl -X POST "https://circleci.com/api/v1.1/project/github/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/envvar?circle-token=$CIRCLE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{ \"name\": \"LAST_DEPLOYED_REVISION_ON_$app_name_uppercase_and_underscored\", \"value\": \"$revision\" }" \
    -s -o /dev/null -w "%{http_code}" | grep "201"
}

_revision_is_newer_than_or_the_same_as_the_deployed_revision () {
  last_deployed_revision_env="LAST_DEPLOYED_REVISION_ON_$app_name_uppercase_and_underscored"
  root_revision=$(git rev-list --max-parents=0 HEAD)
  git merge-base --is-ancestor "${!last_deployed_revision_env:=$root_revision}" "$revision"
}

_ensure_new_revision_is_running () { timeout 10m script/ci/wait_for_new_revision_to_serve_requests.sh "$app_name" "$revision"; }

_heroku_release_json () {
  docker_image=$(curl -s -X GET "https://_:$heroku_token@registry.heroku.com/v2/$app_name/app/manifests/$revision" --header "Accept: application/vnd.docker.distribution.manifest.v2+json" | jq -r ".config.digest")

  if ! [[ "$docker_image" =~ sha256:[A-Fa-f0-9]{64} ]]; then
    echo "Unexpected format for docker image: $docker_image"
  fi

  heroku_release_json='{ "updates": [] }'

  while read -r line; do
    type=$(echo "$line" | cut -f1 -d:)
    command=$(echo "$line" | cut -f2 -d:)

    update_json=$(jq -n \
      --arg type "$type" \
      --arg docker_image "$docker_image" \
      --arg command "$command" \
      '[ { type: $type, docker_image: $docker_image, command: $command } ]')

    heroku_release_json=$(echo "$heroku_release_json" | jq ".updates += $update_json")
  done < Procfile

  # Die if we don't see web mentioned, as a confidence check
  echo "$heroku_release_json" | grep --silent "web"

  echo "$heroku_release_json"
}

_main
