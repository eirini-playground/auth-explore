#!/bin/bash

set -euxo pipefail

appCRDFile="$HOME/workspace/cf-k8s-controllers/config/crd/bases/workloads.cloudfoundry.org_cfapps.yaml"

if [ ! -f "$appCRDFile" ]; then
  echo clone cf-k8s-controllers into $HOME/workspace first please
  exit 1
fi

kubectl apply -f "$appCRDFile"

go run main.go
