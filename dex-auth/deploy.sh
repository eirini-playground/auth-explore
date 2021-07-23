#!/bin/bash

set -euo pipefail

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
        oidc-issuer-url: https://dex.vcap.me:32000
        oidc-client-id: example-app
        oidc-ca-file: /etc/dex-ssl/ca.pem
        oidc-username-claim: preferred_username
        oidc-username-prefix: "oidc:"
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
EOF

kind create cluster --name dex-play --config "$KIND_CONF"

kubectl create namespace dex
kubectl create secret --namespace dex tls dex.vcap.me.tls --cert="$SCRIPT_DIR/ssl/cert.pem" --key="$SCRIPT_DIR/ssl/key.pem"

kubectl create secret --namespace dex \
  generic github-client \
  --from-literal=client-id="$CLIENT_ID" \
  --from-literal=client-secret="$CLIENT_SECRET"

kubectl create -f "$SCRIPT_DIR/dex.yaml"

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-$USERNAME
  namespace: default
subjects:
- kind: User
  name: oidc:$USERNAME
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  apiGroup: rbac.authorization.k8s.io
  name: view
EOF
