#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

"$SCRIPT_DIR/gencert.sh"

KIND_CONF="$(mktemp)"
trap "rm $KIND_CONF" EXIT

cat <<EOF >>"$KIND_CONF"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - containerPath: /ssl
    hostPath: $SCRIPT_DIR/ssl
    readOnly: true
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      extraVolumes:
        - name: ssl-certs
          hostPath: /ssl
          mountPath: /etc/dex-ssl
      extraArgs:
        oidc-issuer-url: https://localhost:32000
        oidc-client-id: example-app
        oidc-ca-file: /etc/dex-ssl/ca.crt
        oidc-username-claim: email
        oidc-username-prefix: "oidc:"
        oidc-groups-claim: groups
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
EOF

kind create cluster --name opa-gatekeeper --config "$KIND_CONF"

kubectl create namespace dex
kubectl create secret --namespace dex tls dex.localhost.tls --cert="$SCRIPT_DIR/ssl/server.crt" --key="$SCRIPT_DIR/ssl/server.key"
kubectl create -f "$SCRIPT_DIR/dex.yaml"

# Install gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.5/deploy/gatekeeper.yaml

# Tell gatekeeper what k8s objects to sync so that they are avaliable to rego rules
kubectl apply -f "$SCRIPT_DIR/gatekeeper-sync.yaml"

# Apply CF CRDs
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd

# Create RBAC roles
kubectl apply -f $SCRIPT_DIR/../cf-roles-model/rbac.yaml

# Create some sample resources
kubectl apply --recursive -f $SCRIPT_DIR/../../cf-crd-explorations/config/samples/cf-crds
