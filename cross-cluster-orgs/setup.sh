#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ip=$(curl -s ipecho.net/plain)
"$SCRIPT_DIR/gencert.sh" "$ip"

passwd_hash=$(htpasswd -bnBC 10 "" password | tr -d ':\n')

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
        oidc-issuer-url: https://$ip.nip.io:32000
        oidc-client-id: example-app
        oidc-ca-file: /etc/dex-ssl/ca.crt
        oidc-username-claim: email
        oidc-username-prefix: "oidc:"
        oidc-groups-claim: groups
EOF

# open oidc-related ports
gcloud -q compute instances add-tags $(hostname) --zone europe-west2-a --tags=$(hostname)
gcloud -q compute firewall-rules delete allow-oidc-$(hostname) || true
gcloud compute firewall-rules create allow-oidc-$(hostname) --allow=tcp:5555,tcp:32000 --target-tags=$(hostname)

KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-2" kind create cluster --name cross-org-2 --config "$KIND_CONF"

# only map port 32000 of cluster 1, which contains dex
cat <<EOF >>"$KIND_CONF"
  extraPortMappings:
  - containerPort: 32000
    hostPort: 32000
    protocol: TCP
EOF
KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-1" kind create cluster --name cross-org-1 --config "$KIND_CONF"

export KUBECONFIG="$SCRIPT_DIR/kubeconfigs/cross-org-1"

kubectl create namespace dex
kubectl create secret --namespace dex tls "dex-tls" --cert="$SCRIPT_DIR/ssl/server.crt" --key="$SCRIPT_DIR/ssl/server.key"

cat <<EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: dex-config
  namespace: dex
data:
  config.yaml: |
    issuer: https://$ip.nip.io:32000
    storage:
      type: kubernetes
      config:
        inCluster: true
    web:
      https: 0.0.0.0:5556
      tlsCert: /etc/dex/tls/tls.crt
      tlsKey: /etc/dex/tls/tls.key
    oauth2:
      skipApprovalScreen: true

    staticClients:
    - id: example-app
      redirectURIs:
      - 'http://$ip.nip.io:5555/callback'
      name: 'Example App'
      secret: ZXhhbXBsZS1hcHAtc2VjcmV0

    enablePasswordDB: true
    staticPasswords:
    - email: "alice@vcap.me"
      # bcrypt hash of the string "password"
      hash: $passwd_hash
      username: "alice"
      userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
    - email: "bob@vcap.me"
      # bcrypt hash of the string "password"
      hash: $passwd_hash
      username: "bob"
      userID: "6aea7e79-474b-4195-b3f2-dc4ea2b28470"
EOF

kubectl create -f "$SCRIPT_DIR/dex.yaml"

apply_resources "$SCRIPT_DIR/kubeconfigs/cross-org-1"
apply_resources "$SCRIPT_DIR/kubeconfigs/cross-org-2"

pushd $SCRIPT_DIR/org-controller
{
  docker build --tag eirini/org-controller:dev .
  kind load docker-image --name cross-org-1 eirini/org-controller:dev
}
popd

kubectl apply -f $SCRIPT_DIR/org-controller.yml
kubectl apply -f $SCRIPT_DIR/org-controller/crds
kubectl -n org create configmap cross-org-1 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-1
kubectl -n org create configmap cross-org-2 --from-file=$SCRIPT_DIR/kubeconfigs/cross-org-2

echo Done
echo In order to login run the following command:
echo example-app --issuer https://$ip.nip.io:32000 --issuer-root-ca ./ssl/ca.crt --listen http://0.0.0.0:5555 --redirect-uri http://$ip.nip.io:5555/callback
echo then navigate to http://$ip.nip.io:5555 to authenticate
