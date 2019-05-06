#!/bin/bash

set -e

projects=("istiotutorial" "knativetutorial" "sandbox")
for i in {200..205}
do
  for p in "${projects[@]}" 
  do
    printf "Creating and Configuring OpenShift Project $p for dev$i \n"
    oc new-project "dev$i-$p" && \
    oc adm policy add-scc-to-user privileged -z default -n "dev$i-$p" && \
    oc adm policy add-scc-to-user anyuid -z default -n  "dev$i-$p" && \
    oc adm policy add-role-to-user admin "dev$i" -n "dev$i-$p"
  done
  # oc new-project "dev$i-istiotutorial" && \
  # oc adm policy add-scc-to-user privileged -z default -n "dev$i-istiotutorial" && \
  # oc adm policy add-scc-to-user anyuid -z default -n  "dev$i-istiotutorial" && \
  # oc new-project "dev$i-knativetutorial" && \
  # oc adm policy add-scc-to-user privileged -z default -n "dev$i-knativetutorial" && \
  # oc adm policy add-scc-to-user anyuid -z default -n "dev$i-knativetutorial" && \
  # oc adm policy add-role-to-user admin "dev$i" -n "dev$i-istiotutorial" && \
  # oc adm policy add-role-to-user admin "dev$i" -n "dev$i-knativetutorial"
done
