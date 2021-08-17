#!/bin/bash

cleanup() {
    unset KUBECONFIG
    kubectl delete -f service-account.yml
    kubectl delete -f cluster-role-binding.yml
    rm -f $caFile
}

trap cleanup EXIT

kubectl create -f service-account.yml
kubectl create -f cluster-role-binding.yml
secretname="$(kubectl get serviceaccount build-robot -o jsonpath="{.secrets[0].name}")"
token="$(kubectl get secret $secretname -o jsonpath="{.data.token}" | base64 -d)"
ca="$(yq eval '.clusters[] | select(.name == "kind-auth").cluster.certificate-authority-data' ~/.kube/config)"
server="$(yq eval '.clusters[] | select(.name == "kind-auth").cluster.server' ~/.kube/config)"
caFile="$(mktemp)"
echo $ca | base64 -d > $caFile

export KUBECONFIG=/dev/null
kubectl --server=$server --certificate-authority=$caFile --token=$token get pods --all-namespaces
