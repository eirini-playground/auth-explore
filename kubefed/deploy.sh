#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
KUBEFED_DIR="$HOME/workspace/kubefed"

if ! [[ -d "$KUBEFED_DIR" ]]; then
  mkdir -p $KUBEFED_DIR
  # the pr-fix-fix-joined-clusters branch contains a fix on fix-joined-kind-clusters.sh
  git -C "$KUBEFED_DIR"/.. clone -b spike-eirini-kubefed git@github.com:eirini-forks/kubefed.git

  pushd $KUBEFED_DIR
  {
    ./scripts/download-binaries.sh
  }
  popd
fi

pass eirini/docker-hub | docker login -u eiriniuser --password-stdin
$HOME/workspace/eirini-controller/deployment/scripts/build.sh

kind create cluster --name kubefed-3
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd
$HOME/workspace/eirini-controller/deployment/scripts/deploy-only.sh --set "workloads.namespaces={federate-me}"
kubectl

kind create cluster --name kubefed-2
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd
$HOME/workspace/eirini-controller/deployment/scripts/deploy-only.sh --set "workloads.namespaces={federate-me}"

kind create cluster --name kubefed-1
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd
$HOME/workspace/eirini-controller/deployment/scripts/deploy-only.sh --set "workloads.namespaces={federate-me}" --set "controller.federated=true"

pushd $KUBEFED_DIR
{
  KIND_CLUSTER_NAME=kubefed-1 make deploy.kind
  kubefedctl join kind-kubefed-2
  kubefedctl join kind-kubefed-3
  git checkout spike-eirini-kubefed
  ./scripts/fix-joined-kind-clusters.sh
}
popd

kubectl label -n kube-federation-system kubefedclusters.core.kubefed.io kind-kubefed-1 isolationSegment=public
kubectl label -n kube-federation-system kubefedclusters.core.kubefed.io kind-kubefed-2 isolationSegment=private
kubectl label -n kube-federation-system kubefedclusters.core.kubefed.io kind-kubefed-3 isolationSegment=private

# kubefedctl federate --filename ../cf-roles-model/rbac.yaml | kubectl apply -f -

# kubectl create ns federate-me
kubefedctl federate ns federate-me
kubefedctl enable lrps.eirini.cloudfoundry.org

## Federated deployments
#kubefedctl federate --filename deployment.yaml | kubectl apply -f -
#kubectl apply -f deployment-replicaset-scheduling-pref.yaml

## Federating role bindings
#kubectl apply -f alice-space-developer-rolebinding.yml
#kubefedctl federate rolebinding alice-space-developer -n federate-me --enable-type

##federate CF App
#kubectl apply -n federate-me -f ./../../cf-crd-explorations/config/samples/cf-crds/app.yaml
#kubefedctl federate app my-app-guid -n federate-me --enable-type
