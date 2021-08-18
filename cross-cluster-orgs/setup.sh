#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

apply_resources() {
  # Apply CF CRDs
  KUBECONFIG=$1 kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd

  # Create RBAC roles
  KUBECONFIG=$1 kubectl apply -f $SCRIPT_DIR/../cf-roles-model/rbac.yaml
}

KIND_CONF="$(mktemp)"
trap "rm $KIND_CONF" EXIT

cat <<EOF >>"$KIND_CONF"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: 172.17.0.1
EOF

KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-1" kind create cluster --name cross-org-1 --config "$KIND_CONF"
KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-2" kind create cluster --name cross-org-2 --config "$KIND_CONF"

apply_resources "$SCRIPT_DIR/kubeconfigs/cross-org-1"
apply_resources "$SCRIPT_DIR/kubeconfigs/cross-org-2"

pushd $SCRIPT_DIR/org-controller
{
  docker build --tag eirini/org-controller:dev .
  kind load docker-image --name cross-org-1 eirini/org-controller:dev
}
popd

export KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-1"
kubectl apply -f $SCRIPT_DIR/org-controller.yml
kubectl apply -f $SCRIPT_DIR/org-controller/crds
kubectl -n org create configmap cross-org-1 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-1
kubectl -n org create configmap cross-org-2 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-2

echo Done
