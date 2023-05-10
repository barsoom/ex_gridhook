#!/bin/sh
set -e

app_name=auctionet-ex-gridhook

curl -n -X PATCH https://api.heroku.com/apps/$app_name/formation \
  -d "{ \"updates\":
        [
            { \"type\": \"web\", \"docker_image\": \"$WEB_IMAGE_ID\" }
        ]
    }" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3.docker-releases" \
  -H "Authorization: Bearer $HEROKU_API_KEY"

ruby script/ci/support/wait_for_new_revision_to_serve_requests.rb $app_name $CIRCLE_SHA1
