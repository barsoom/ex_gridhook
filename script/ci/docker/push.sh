#!/bin/sh

revision=$(git rev-parse HEAD)

docker push registry.heroku.com/auctionet-ex-gridhook/web:$revision
