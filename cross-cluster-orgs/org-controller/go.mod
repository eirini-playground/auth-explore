module code.cloudfoundry.org/org-controller

go 1.16

replace github.com/go-logr/logr v1.0.0 => github.com/go-logr/logr v0.4.0

require (
	code.cloudfoundry.org/eirini v0.0.0-20210811000933-555fdb299eeb
	code.cloudfoundry.org/lager v2.0.0+incompatible
	github.com/pkg/errors v0.9.1
	k8s.io/api v0.22.0
	k8s.io/apimachinery v0.22.0
	k8s.io/client-go v0.22.0
	k8s.io/code-generator v0.22.0
	sigs.k8s.io/controller-runtime v0.9.6
	sigs.k8s.io/controller-tools v0.6.2
)
