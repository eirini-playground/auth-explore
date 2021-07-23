#!/bin/bash

set -euo pipefail

kubectl apply -f https://get.pinniped.dev/latest/install-pinniped-concierge.yaml || true
sleep 1
kubectl apply -f https://get.pinniped.dev/latest/install-pinniped-concierge.yaml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

terraform -chdir="$SCRIPT_DIR/terraform" init -backend-config="prefix=terraform/state/dex-pinniped" -upgrade=true
LOADBALANCER_IP="$(terraform -chdir=$SCRIPT_DIR/terraform output -raw static_ip)"

cat <<EOF | kubectl apply -f -
---
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
kind: JWTAuthenticator
metadata:
   name: my-jwt-authenticator
spec:
   issuer: https://$LOADBALANCER_IP.nip.io
   audience: cf-cli
   claims:
     username: email
   tls:
     certificateAuthorityData: $(base64 -w 0 $SCRIPT_DIR/ssl/ca.pem)
EOF
