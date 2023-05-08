#!/bin/sh

stage=$1

docker push registry.heroku.com/auctionet-${CIRCLE_PROJECT_REPONAME}-${stage}:latest
