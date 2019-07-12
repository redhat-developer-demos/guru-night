#!/bin/bash

set -eu
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
    printf "Creating and Configuring OpenShift Project $openshiftProject for user $openshiftUser \n"
    oc new-project "$openshiftProject" --skip-config-write=true>&- && \
    oc label namespace "$openshiftProject" knative-eventing-injection=enabled  && \
    oc create -f $CONFIGS_DIR/workshop-student-project-role.yaml -n "$openshiftProject" && \
    oc adm policy add-scc-to-user privileged -z default -n "$openshiftProject" && \
    oc adm policy add-scc-to-user anyuid -z default -n  "$openshiftProject" && \
    oc policy add-role-to-user admin "$openshiftUser" -n "$openshiftProject" && \
    oc policy add-role-to-user view "$openshiftUser" -n "istio-system" 
    oc policy add-role-to-user workshop-student-project "$openshiftUser" --role-namespace="$openshiftProject" -n "$openshiftProject"
  done
  ((i++))
done
