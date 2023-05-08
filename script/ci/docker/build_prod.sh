#!/bin/sh
set -e

REVISION=$CIRCLE_SHA1 make prod-image

docker tag ${CIRCLE_PROJECT_REPONAME}:web registry.heroku.com/auctionet-${CIRCLE_PROJECT_REPONAME}-production/web:latest

web_image_id=`docker inspect ${CIRCLE_PROJECT_REPONAME}:web --format={{.Id}}`

echo "export WEB_IMAGE_ID=$web_image_id" >> $BASH_ENV
