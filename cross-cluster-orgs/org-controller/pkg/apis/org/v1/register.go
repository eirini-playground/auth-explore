package v1

import (
	orgv1 "code.cloudfoundry.org/org-controller/pkg/apis/org"
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

// GroupVersion is the identifier for the API which includes
// the name of the group and the version of the API
var SchemeGroupVersion = schema.GroupVersion{
	Group:   orgv1.GroupName,
	Version: "v1",
}

// create a SchemeBuilder which uses functions to add types to
// the scheme
var (
	schemeBuilder = runtime.NewSchemeBuilder(addKnownTypes)
	AddToScheme   = schemeBuilder.AddToScheme
)

func Resource(resource string) schema.GroupResource {
	return SchemeGroupVersion.WithResource(resource).GroupResource()
}

func addKnownTypes(scheme *runtime.Scheme) error {
	scheme.AddKnownTypes(
		SchemeGroupVersion,
		&Org{},
		&OrgList{},
		&GlobalUser{},
		&GlobalUserList{},
	)

	meta_v1.AddToGroupVersion(scheme, SchemeGroupVersion)
	return nil
}
