#!/bin/sh
set -e

REVISION=$CIRCLE_SHA1 make test-image
