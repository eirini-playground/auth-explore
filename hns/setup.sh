#!/bin/bash

set -euxo pipefail

clusterName=hns-play
hncVersion=v0.8.0
hncPlatform=linux_amd64

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

#install hns kubectl plugin
curl -L https://github.com/kubernetes-sigs/multi-tenancy/releases/download/hnc-${hncVersion}/kubectl-hns_${hncPlatform} -o "$HOME/bin/kubectl-hns"
chmod +x "$HOME/bin/kubectl-hns"

# setup cluster with HNS controller
kind create cluster --name "$clusterName"

kubectl label ns kube-system hnc.x-k8s.io/excluded-namespace=true --overwrite
kubectl label ns kube-public hnc.x-k8s.io/excluded-namespace=true --overwrite
kubectl label ns kube-node-lease hnc.x-k8s.io/excluded-namespace=true --overwrite
kubectl apply -f https://github.com/kubernetes-sigs/multi-tenancy/releases/download/hnc-${hncVersion}/hnc-manager.yaml

kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd
kubectl apply -f $SCRIPT_DIR/../cf-roles-model/rbac.yaml

# pushd $SCRIPT_DIR/org-controller
# {
#   docker build --tag eirini/org-controller:dev .
#   kind load docker-image --name cross-org-1 eirini/org-controller:dev
# }
# popd

# kubectl apply -f $SCRIPT_DIR/org-controller.yml
# kubectl apply -f $SCRIPT_DIR/org-controller/crds
# kubectl -n org create configmap cross-org-1 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-1
# kubectl -n org create configmap cross-org-2 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-2

echo Done
