#!/bin/bash

set -euo pipefail

echo "The client ID and the client secret can be taken from GCP Console -> API and services -> Credentials -> OAuth 2.0 Client IDs -> k8s OIDC explore. Make sure to replace REDACTED in this file and cluster.yml before deploying"
exit 1

kind create cluster --name goog-play --config cluster.yml
kubectl apply -f k8s/alice-role-binding.yml

go get github.com/micahhausler/k8s-oidc-helper

k8s-oidc-helper --client-id REDACTED.apps.googleusercontent.com --client-secret REDACTED
