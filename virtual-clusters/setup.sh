#!/bin/bash

export CLUSTER_NAME="virtual-cluster" &&
  kind create cluster --name ${CLUSTER_NAME} --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
VC_DIR=$SCRIPT_DIR/../../cluster-api-provider-nested/virtualcluster
if [ ! -d $VC_DIR ]; then
  pushd $HOME/workspace
  {
    git clone https://github.com/kubernetes-sigs/cluster-api-provider-nested.git
    # workaround for https://github.com/kubernetes-sigs/cluster-api-provider-nested/issues/198
    git checkout ea5f01b
  }
  popd
fi

kubectl apply -f $VC_DIR/config/crd/tenancy.x-k8s.io_clusterversions.yaml
kubectl apply -f $VC_DIR/config/crd/tenancy.x-k8s.io_virtualclusters.yaml

kubectl apply -f $VC_DIR/config/setup/all_in_one.yaml

kubectl apply -f $VC_DIR/config/sampleswithspec/clusterversion_v1_nodeport.yaml

kubectl vc create -f $VC_DIR/config/sampleswithspec/virtualcluster_1_nodeport.yaml -o vc-1.kubeconfig

# Workaround for kind only
# Retrieve the tenant namespace
VC_NAMESPACE="$(kubectl get VirtualCluster vc-sample-1 -o json | jq -r '.status.clusterNamespace')"

# The svc node port exposed
VC_SVC_PORT="$(kubectl get -n ${VC_NAMESPACE} svc/apiserver-svc -o json | jq '.spec.ports[0].nodePort')"

# Remove the container if there is any
#$ docker rm -f ${CLUSTER_NAME}-kind-proxy-${VC_SVC_PORT} || true
# Create this sidecar container
docker run -d --restart always \
  --name ${CLUSTER_NAME}-kind-proxy-${VC_SVC_PORT} \
  --publish 127.0.0.1:${VC_SVC_PORT}:${VC_SVC_PORT} \
  --link ${CLUSTER_NAME}-control-plane:target \
  --network kind \
  alpine/socat -dd \
  tcp-listen:${VC_SVC_PORT},fork,reuseaddr tcp-connect:target:${VC_SVC_PORT}

# And update the vc-1.kubeconfig
sed -i".bak" "s|.*server:.*|    server: https://127.0.0.1:${VC_SVC_PORT}|" vc-1.kubeconfig
# End of Workaround for kind only

kubectl apply --kubeconfig vc-1.kubeconfig -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deploy
  labels:
    app: vc-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vc-test
  template:
    metadata:
      labels:
        app: vc-test
    spec:
      containers:
      - name: poc
        image: busybox
        command:
        - top
EOF
