#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CF_CRD_EXPLORE_PATH="$SCRIPT_DIR/../../cf-crd-explorations"

export REGISTRY_TAG_BASE=eirini/cf-crd-staging-spike/buildpack
export PACKAGE_REGISTRY_TAG_BASE="eirini/cf-crd-staging-spike/packages"
export REGISTRY_SECRET="app-registry-credentials"

pushd "$CF_CRD_EXPLORE_PATH"
{
  make run
}
popd
