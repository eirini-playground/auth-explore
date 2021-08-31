#!/bin/bash

set -euxo pipefail

clusterName=hns-play
hncVersion=v0.8.0
hncPlatform=linux_amd64

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

waitForNS() {
  local ok=false ns name
  ns=${1:?namespace please}
  name=${2:?name please}

  for _ in {1..20}; do
    if [ "$(kubectl get subnamespaceanchor -n $ns $name -ojsonpath='{.status.status}')" = "Ok" ]; then
      ok=true
      break
    fi
    sleep 0.1
  done

  if ! $ok; then
    echo "tired of waiting for $ns/$name"
    exit 1
  fi
}

#install hns kubectl plugin
curl -L https://github.com/kubernetes-sigs/multi-tenancy/releases/download/hnc-${hncVersion}/kubectl-hns_${hncPlatform} -o "$HOME/bin/kubectl-hns"
chmod +x "$HOME/bin/kubectl-hns"

# setup cluster with HNS controller
if ! kind get clusters | grep -q "$clusterName"; then
  kind create cluster --name "$clusterName"

  kubectl label ns kube-system hnc.x-k8s.io/excluded-namespace=true --overwrite
  kubectl label ns kube-public hnc.x-k8s.io/excluded-namespace=true --overwrite
  kubectl label ns kube-node-lease hnc.x-k8s.io/excluded-namespace=true --overwrite
  kubectl apply -f https://github.com/kubernetes-sigs/multi-tenancy/releases/download/hnc-${hncVersion}/hnc-manager.yaml
  kubectl rollout status deployment/hnc-controller-manager -w -n hnc-system
  sleep 10
fi

kubectl create namespace cf
kubectl apply -f $SCRIPT_DIR/roles.yaml
kubectl apply -f $SCRIPT_DIR/admin-role-bindings.yaml

kubectl hns create -n cf org1 --as dave
kubectl hns create -n cf org2 --as dave

waitForNS cf org1
waitForNS cf org2

kubectl apply -f $SCRIPT_DIR/org-manager-role-bindings.yaml

kubectl hns create -n org1 space1 --as charlie
kubectl hns create -n org1 space2 --as charlie
kubectl hns create -n org2 space3 --as evan
kubectl hns create -n org2 space4 --as evan

waitForNS org1 space1
waitForNS org2 space3

kubectl apply -f $SCRIPT_DIR/developer-role-bindings.yaml
kubectl get pods -n space1 --as alice
kubectl get pods -n space3 --as bob

echo Done
