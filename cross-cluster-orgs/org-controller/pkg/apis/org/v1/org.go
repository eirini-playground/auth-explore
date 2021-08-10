// +kubebuilder:validation:Optional
package v1

import (
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:resource:shortName=org
// +kubebuilder:subresource:status
type Org struct {
	meta_v1.TypeMeta   `json:",inline"`
	meta_v1.ObjectMeta `json:"metadata,omitempty"`

	Spec   OrgSpec   `json:"spec"`
	Status OrgStatus `json:"status"`
}

type OrgSpec struct {
	Namespaces OrgNamespace `json:"namespaces"`
	Users      []string     `json:"users"`
}

type OrgNamespace struct {
	ClusterContext string `json:"cluster_context"`
	Namespace      string `json:"namespace"`
}

type OrgStatus struct{}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type OrgList struct {
	meta_v1.TypeMeta `json:",inline"`
	meta_v1.ListMeta `json:"metadata"`

	Items []Org `json:"items"`
}
