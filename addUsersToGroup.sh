#!/bin/bash

set -e

echo "Creating Workshop Students Cluster Role"

oc apply -f workshop-student-roles.yaml

groupUsers="";
echo "Adding Users to Group workshop-students"

# Chnage this range based on your user setup
groupUsers=""
for i in {1..176}
do
  yq w  -i workshop-students-group.yaml \
    "users[+]"  $(printf "dev%03d" $i)
done

echo "Creating Workshop Students Group"
oc apply -f workshop-students-group.yaml

# Reset it back so that can be used with another setup
yq d -i workshop-students-group.yaml "users[*]"
