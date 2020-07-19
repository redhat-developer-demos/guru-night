#!/bin/bash 

set -eu 
set -o pipefail 

oc create namespace advanced-cluster-management || true

cat <<EOF | oc -n advanced-cluster-management apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: advanced-cluster-management
spec:
  targetNamespaces:
  - advanced-cluster-management
EOF

cat <<EOF | oc -n advanced-cluster-management apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
spec:
  sourceNamespace: openshift-marketplace
  source: redhat-operators
  channel: release-1.0
  installPlanApproval: Automatic
  name: advanced-cluster-management
EOF

oc -n advanced-cluster-management create secret docker-registry advanced-cluster-management-registry \
  --docker-server=registry.access.redhat.com/rhacm1-tech-preview \
  --docker-username="$RH_REGISTRY_USER" --docker-password="$RH_REGISTRY_USER_PASS"

cat <<EOF | oc -n advanced-cluster-management apply -f -
apiVersion: operators.open-cluster-management.io/v1beta1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: advanced-cluster-management
spec:
  imagePullSecret: advanced-cluster-management-registry
EOF