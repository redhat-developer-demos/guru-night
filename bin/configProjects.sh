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
    # echo "$openshifProject"
    printf "Creating and Configuring OpenShift Project $openshiftProject for user $openshiftUser \n"
    oc new-project "$openshiftProject" && \
    oc adm policy add-scc-to-user privileged -z default -n "$openshiftProject" && \
    oc adm policy add-scc-to-user anyuid -z default -n  "$openshiftProject" && \
    oc adm policy add-role-to-user admin "$openshiftUser" --role-namespace="$openshiftProject" -n "$openshiftProject"
  done
  ((i++))
done

oc adm policy add-cluster-role-to-group view workshop-students --namespace='istio-system'
