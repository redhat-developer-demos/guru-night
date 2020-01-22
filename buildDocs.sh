#!/bin/bash

# Check if pre-req commands exists
hash yq
hash antora

ATTRIBUTES_FILE=${1:-workshop-attributes-intro.yaml}

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

rm -rf ./gh-pages .cache

yq w workshop.yaml -s $_CURR_DIR/$ATTRIBUTES_FILE > $_CURR_DIR/workshop-site.yaml

antora --pull --stacktrace  $_CURR_DIR/workshop-site.yaml

open gh-pages/index.html