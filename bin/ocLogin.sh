#!/bin/bash
set -u

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source $_CURR_DIR/setEnv.sh

oc login -u ${1:-$OPENSHIFT_ADMIN_USER} $OPENSHIFT_API_URL
