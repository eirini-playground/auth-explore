#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
KUBEFED_DIR="$HOME/workspace/kubefed"

if ! [[ -d "$KUBEFED_DIR" ]]; then
  mkdir -p $KUBEFED_DIR
  # the pr-fix-fix-joined-clusters branch contains a fix on fix-joined-kind-clusters.sh
  git -C "$KUBEFED_DIR"/.. clone -b pr-fix-fix-joined-clusters git@github.com:eirini-forks/kubefed.git

  pushd $KUBEFED_DIR
  {
    ./scripts/download-binaries.sh
  }
  popd
fi

kind create cluster --name kubefed-2
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd

kind create cluster --name kubefed-1
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd

pushd $KUBEFED_DIR
{
  KIND_CLUSTER_NAME=kubefed-1 make deploy.kind
  kubefedctl join kind-kubefed-2
  ./scripts/fix-joined-kind-clusters.sh
}
popd

kubefedctl federate --filename ../cf-roles-model/rbac.yaml | kubectl apply -f -

kubectl create ns federate-me
kubefedctl federate ns federate-me

# Federated deployments
kubefedctl federate --filename deployment.yaml | kubectl apply -f -
kubectl apply -f deployment-replicaset-scheduling-pref.yaml

# Federating role bindings
kubectl apply -f alice-space-developer-rolebinding.yml
kubefedctl federate rolebinding alice-space-developer -n federate-me --enable-type

#federate CF App
kubectl apply -n federate-me -f ./../../cf-crd-explorations/config/samples/cf-crds/app.yaml
kubefedctl federate app my-app-guid -n federate-me --enable-type
