package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Ingress"
  input.request.userInfo.username == "oidc:alice"
  msg := "alice isn't allowed to play with Ingresses"
}
