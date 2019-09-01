#!/bin/bash

  # Check if pre-req commands exists
  hash yq
  hash antora

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
rm -rf ./gh-pages .cache

yq w workshop.yaml -s workshop-attributes.yaml > workshop-site.yaml

antora --pull --stacktrace  workshop-site.yaml

open gh-pages/index.html