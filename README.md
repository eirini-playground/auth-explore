# AuthN / AuthZ Exploration

## 1. Using UAA as an Open ID Connect Provider to K8s

See [kind-uaa-authN](kind-uaa-authN/README.md).

This contains configuration and scripts to deploy a kind cluster using OIDC to
authenticate users stored in UAA, itself running in the cluster.

When the [alice-role-binding](kind-uaa-authN/k8s/alice-role-binding.yml) is
applied, the user alice gets the default view ClusterRole in the default
namespace, and so can, for example, list pods in the default namespace. Listing
pods in another namespace is denied.

Together, these show authN working with OIDC and UAA, and authZ with built-in
k8s RBAC.

## 2. Open Policy Agent
