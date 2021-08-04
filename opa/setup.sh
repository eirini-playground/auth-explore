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

kind create cluster --name opa-play --config "$KIND_CONF"

kubectl create namespace dex
kubectl create secret --namespace dex tls dex.localhost.tls --cert="$SCRIPT_DIR/ssl/server.crt" --key="$SCRIPT_DIR/ssl/server.key"
kubectl create -f "$SCRIPT_DIR/dex.yaml"

kubectl create namespace opa

kubectl -n opa create secret tls opa-server --cert=ssl/server.crt --key=ssl/server.key
kubectl -n opa apply -f admission-controller.yaml

kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore

cat <<EOF | kubectl apply -f -
kind: ValidatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1beta1
metadata:
  name: opa-validating-webhook
webhooks:
  - name: validating-webhook.openpolicyagent.org
    namespaceSelector:
      matchExpressions:
      - key: openpolicyagent.org/webhook
        operator: NotIn
        values:
        - ignore
    rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      caBundle: $(cat ssl/ca.crt | base64 | tr -d '\n')
      service:
        namespace: opa
        name: opa
EOF

# Apply the OPA rules, it is important to create it in the opa namespace as this is how OPA knows that this is a rule
kubectl -n opa create configmap space-developer --from-file=space-developer.rego

# Apply CF CRDs
kubectl apply -k $SCRIPT_DIR/../../cf-crd-explorations/config/crd

# Create RBAC roles
kubectl apply -f $SCRIPT_DIR/../cf-roles-model/rbac.yaml

# Create some sample resources
kubectl apply --recursive -f $SCRIPT_DIR/../../cf-crd-explorations/config/samples/cf-crds
