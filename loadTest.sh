#!/bin/bash

set -eu

NS=${1:-'tutorial'}

for (( i = 0; i < 70; i++ )); do
 echo "Creating App for User $i"
 oc  new-app --namespace="$NS" nodeshift/centos7-s2i-nodejs:10.x~https://github.com/redhat-developer-demos/linux-container-world-apps \
 --context-dir=nodejs \
 --name="helloworld-$i" &> /dev/null
 oc expose svc "helloworld-$i" 
done
