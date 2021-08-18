// +kubebuilder:validation:Optional
package v1

import (
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient:nonNamespaced
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:resource:shortName=org,scope=Cluster
// +kubebuilder:subresource:status
type Org struct {
	meta_v1.TypeMeta   `json:",inline"`
	meta_v1.ObjectMeta `json:"metadata,omitempty"`

	Spec   OrgSpec   `json:"spec"`
	Status OrgStatus `json:"status"`
}

type OrgSpec struct {
	Users  []User  `json:"users"`
	Spaces []Space `json:"spaces"`
}

type User struct {
	Name  string   `json:"name"`
	Roles []string `json:"roles"`
}

type Space struct {
	Name        string `json:"name"`
	ClusterName string `json:"cluster_name"`
	Users       []User `json:"users"`
}

type OrgStatus struct{}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type OrgList struct {
	meta_v1.TypeMeta `json:",inline"`
	meta_v1.ListMeta `json:"metadata"`

	Items []Org `json:"items"`
}
