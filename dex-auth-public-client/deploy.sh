#!/bin/bash

set -euo pipefail

export CLIENT_ID
export CLIENT_SECRET

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

"$SCRIPT_DIR/gencert.sh"

KIND_CONF="$(mktemp)"
trap "rm $KIND_CONF" EXIT

cat <<EOF >>"$KIND_CONF"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.20.2
  extraMounts:
  - containerPath: /ssl
    hostPath: $SCRIPT_DIR/ssl
    readOnly: true
- role: worker
  image: kindest/node:v1.20.2
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
        oidc-client-id: cf-cli
        oidc-ca-file: /etc/dex-ssl/ca.pem
        oidc-username-claim: preferred_username
        oidc-username-prefix: "oidc:"
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
EOF

kind create cluster --name dex-play-public-client --config "$KIND_CONF"

kubectl create namespace dex
kubectl create secret --namespace dex tls localhost.tls --cert="$SCRIPT_DIR/ssl/cert.pem" --key="$SCRIPT_DIR/ssl/key.pem"

kubectl create secret --namespace dex \
  generic github-client \
  --from-literal=client-id="$CLIENT_ID" \
  --from-literal=client-secret="$CLIENT_SECRET"

kubectl create -f "$SCRIPT_DIR/dex.yaml"
