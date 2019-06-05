#!/bin/bash

set -e

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source $_CURR_DIR/setEnv.sh

projects=($PROJECTS)
i=$USERS_FROM
j=$USERS_TO
while [[ $i -le $j ]];
do
  for p in "${projects[@]}" 
  do
    openshiftUser=$(printf "$USER_SUFFIX%d" $i)
    openshiftProject=$(printf '%s-%d' $p $i)
    printf "Configuring Quota for Project $openshiftProject \n"
    yq w $CONFIGS_DIR/podQuota.yaml metadata.namespace "$openshiftProject" | oc apply -f - 
  done
  ((i++))
done
