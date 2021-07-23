#!/bin/bash

set -euo pipefail

kind create cluster --name uaa-play --config cluster.yml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
kubectl create secret tls uaa-tls --key uaa/uaa.key --cert uaa/uaa.crt
kubectl apply -f uaa/uaa-ingress.yml
kubectl apply -f k8s/alice-role-binding.yml

cp uaa/_values.yml ../../uaa/k8s/templates/values/
pushd ../../uaa/k8s
make apply
popd
