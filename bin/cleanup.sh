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
    openshiftUser=$(printf 'user%d' $i)
    openshiftProject=$(printf '%s-%d' $p $i)
    printf "Deleting OpenShift Project $openshiftProject \n"
    oc adm policy remove-scc-from-user privileged -z default -n "$openshiftProject" && \
    oc adm policy remove-scc-from-user anyuid -z default -n  "$openshiftProject" && \
    oc adm policy remove-role-from-user admin "$openshiftUser" --role-namespace="$openshiftProject" -n  "$openshiftProject"&& \
    oc delete project --ignore-not-found=true "$openshiftProject"
  done
  ((i++))
done

# remove istio view role on istio-system
oc adm policy remove-cluster-role-from-group view workshop-students -n istio-system

# Delete the workshop students group 
oc delete groups.user.openshift.io workshop-students

# Delete the workshop student role 
oc delete clusterrole workshop-student

#TODO delete the users and remove htpassidp from oauth