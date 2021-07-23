#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

terraform -chdir="$SCRIPT_DIR/terraform" init -backend-config="prefix=terraform/state/dex-pinniped" -upgrade=true
LOADBALANCER_IP="$(terraform -chdir=$SCRIPT_DIR/terraform output -raw static_ip)"

"$SCRIPT_DIR/gencert.sh" "$LOADBALANCER_IP.nip.io"

kubectl delete namespace dex || true
kubectl delete clusterrolebinding dex || true
kubectl delete clusterrole dex || true

kubectl create namespace dex
kubectl create secret --namespace dex tls dex.vcap.me.tls --cert="$SCRIPT_DIR/ssl/cert.pem" --key="$SCRIPT_DIR/ssl/key.pem"

kubectl create -f "$SCRIPT_DIR/dex.yaml"

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: dex
  namespace: dex
spec:
  type: LoadBalancer
  loadBalancerIP: $LOADBALANCER_IP
  selector:
    app: dex
  ports:
  - name: dex
    protocol: TCP
    port: 443
    targetPort: 5556
EOF

cat <<EOF | kubectl apply -f -
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dex
  namespace: dex
data:
  config.yaml: |
    issuer: https://$LOADBALANCER_IP.nip.io
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
    - id: cf-cli
      name: 'CF CLI'
      redirectURIs:
      - 'http://127.0.0.1:5555/callback'
      public: true

    enablePasswordDB: true
    staticPasswords:
    - email: "admin@vcap.me"
      # bcrypt hash of the string "password"
      hash: "\$2a\$10\$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
      username: "admin"
      userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
    - email: "alice@example.com"
      # bcrypt hash of the string "password"
      hash: "\$2a\$10\$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
      username: "alice"
      userID: "1827c128-5a37-4277-bb38-7464575cc714"
EOF
