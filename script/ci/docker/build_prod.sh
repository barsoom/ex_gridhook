#!/bin/sh
set -e

REVISION=$CIRCLE_SHA1 make prod-image

docker tag ex-gridhook:web registry.heroku.com/auctionet-ex-gridhook/web:latest

web_image_id=`docker inspect ex-gridhook:web --format={{.Id}}`

echo "export WEB_IMAGE_ID=$web_image_id" >> $BASH_ENV
