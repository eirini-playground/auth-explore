#!/bin/bash

set -euo pipefail

ORG_CONTROLLER_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
ORG_CRD_DIR="$ORG_CONTROLLER_ROOT/code.cloudfoundry.org/crds"
CODEGEN_PKG=${CODEGEN_PKG:-$(
  cd "${ORG_CONTROLLER_ROOT}"
  ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../code-generator
)}

CONTROLLERGEN_PKG=${CONTROLLERGEN_PKG:-$(
  cd "${ORG_CONTROLLER_ROOT}"
  ls -d -1 ./vendor/sigs.k8s.io/controller-tools 2>/dev/null || echo ../controller-tools
)}

cleanup() {
  rm -rf $ORG_CONTROLLER_ROOT/code.cloudfoundry.org
}

trap cleanup EXIT

rm -rf $ORG_CONTROLLER_ROOT/pkg/generated

# generate the code with:
# --output-base    because this script should also be able to run inside the vendor dir of
#                  k8s.io/kubernetes. The output-base is needed for the generators to output into the vendor dir
#                  instead of the $GOPATH directly. For normal projects this can be dropped.
/bin/bash "${CODEGEN_PKG}/generate-groups.sh" all \
  code.cloudfoundry.org/org-controller/pkg/generated code.cloudfoundry.org/org-controller/pkg/apis \
  org:v1 \
  --output-base "$(dirname "${BASH_SOURCE[0]}")/.." \
  --go-header-file "${ORG_CONTROLLER_ROOT}/hack/boilerplate.go.txt"

cp -R $ORG_CONTROLLER_ROOT/code.cloudfoundry.org/org-controller/pkg/generated $ORG_CONTROLLER_ROOT/pkg
cp -R $ORG_CONTROLLER_ROOT/code.cloudfoundry.org/org-controller/pkg/apis/* $ORG_CONTROLLER_ROOT/pkg/apis/

# CRD Generation

mkdir -p "$ORG_CRD_DIR"

pushd "$ORG_CONTROLLER_ROOT"
{
  go run vendor/sigs.k8s.io/controller-tools/cmd/controller-gen/main.go crd output:dir="$ORG_CRD_DIR" paths=./pkg/apis/...
  cp -r "$ORG_CRD_DIR" "$ORG_CONTROLLER_ROOT/crds/"
}
popd
