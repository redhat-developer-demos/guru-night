#!/bin/bash

set -u

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source $_CURR_DIR/setEnv.sh

if [ "${KUBECONFIG}x" = "x" ];
then
  echo "KUBECONFIG does not exist, set to OCP Cluster's kubeconfig file"
  exit 1
fi

oc login -u system:admin >&-
