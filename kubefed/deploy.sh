#!/bin/bash

set -euxo pipefail

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
kind create cluster --name kubefed-1

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

kubefedctl federate --filename deployment.yaml | kubectl apply -f -
kubectl apply -f deployment-replicaset-scheduling-pref.yaml
