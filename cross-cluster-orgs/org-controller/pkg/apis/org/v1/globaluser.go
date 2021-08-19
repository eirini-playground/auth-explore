// +kubebuilder:validation:Optional
package v1

import (
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient:nonNamespaced
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:resource:shortName=gu,scope=Cluster
// +kubebuilder:subresource:status
type GlobalUser struct {
	meta_v1.TypeMeta   `json:",inline"`
	meta_v1.ObjectMeta `json:"metadata,omitempty"`

	Spec   GlobalUserSpec   `json:"spec"`
	Status GlobalUserStatus `json:"status"`
}

type GlobalUserSpec struct {
	Roles []string `json:"roles"`
}

type GlobalUserStatus struct{}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type GlobalUserList struct {
	meta_v1.TypeMeta `json:",inline"`
	meta_v1.ListMeta `json:"metadata"`

	Items []GlobalUser `json:"items"`
}
