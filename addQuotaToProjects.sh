#!/bin/bash

set -e

projects=("istiotutorial" "knativetutorial" "sandbox")
for i in {200..400}
do
  for p in "${projects[@]}" 
  do
    _p=$(printf "dev%03d-$p" $i )
    printf "Configuring Quota for Project $_p \n"
    yq w podQuota.yaml metadata.namespace "$_p" | oc apply -f - 
  done
done
