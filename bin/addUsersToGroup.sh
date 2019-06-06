#!/bin/bash
set -e

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source $_CURR_DIR/setEnv.sh

echo "Creating Workshop Students Cluster Role"

oc apply -f $CONFIGS_DIR/workshop-student-roles.yaml

groupUsers="";
echo "Adding Users to Group workshop-students"

# Chnage this range based on your user setup
groupUsers=""
i=$USERS_FROM
j=$USERS_TO
while [[ $i -le $j ]];
do
  yq w -i $CONFIGS_DIR/workshop-students-group.yaml \
    "users[+]" $(printf "$USER_SUFFIX%d" $i)
  ((i++))
done

oc apply -f $CONFIGS_DIR/workshop-students-group.yaml

# Add role to workshop students
oc adm policy add-cluster-role-to-group workshop-student workshop-students

# Reset it back so that can be used with another setup
yq d -i $CONFIGS_DIR/workshop-students-group.yaml "users" "[]"
