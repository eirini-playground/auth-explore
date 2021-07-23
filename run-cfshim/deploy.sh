#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEX_AUTH_PATH="$SCRIPT_DIR/../dex-auth"
CF_CRD_EXPLORE_PATH="$SCRIPT_DIR/../../cf-crd-explorations"

export CLIENT_ID="..."
export CLIENT_SECRET="..."
export USERNAME="..."

echo "See dex-auth/README.MD to fill the values above"
exit 1

$DEX_AUTH_PATH/deploy.sh

kubectl create namespace cf-workloads
helm install eirini-controller https://github.com/cloudfoundry-incubator/eirini-controller/releases/download/v0.1.0/eirini-controller-0.1.0.tgz
make -C "$CF_CRD_EXPLORE_PATH" install
