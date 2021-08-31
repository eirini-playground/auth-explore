#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEX_AUTH_PATH="$SCRIPT_DIR/../dex-auth"
CF_CRD_EXPLORE_PATH="$SCRIPT_DIR/../../cf-crd-explorations"

export CLIENT_ID="..."
export CLIENT_SECRET="..."

echo "See dex-auth/README.MD to fill the values above"
exit 1

$DEX_AUTH_PATH/deploy.sh

kubectl apply --filename https://github.com/pivotal/kpack/releases/download/v0.3.1/release-0.3.1.yaml

kubectl create namespace cf-workloads
helm install eirini-controller https://github.com/cloudfoundry-incubator/eirini-controller/releases/download/v0.1.0/eirini-controller-0.1.0.tgz

export REGISTRY_TAG_BASE=eirini/cf-crd-staging-spike/buildpack
export PACKAGE_REGISTRY_TAG_BASE="eirini/cf-crd-staging-spike/packages"
export REGISTRY_SECRET="app-registry-credentials"

pushd "$CF_CRD_EXPLORE_PATH"
{
  make install
}
popd
