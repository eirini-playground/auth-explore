package reconcilers

import (
	"context"
	"fmt"

	"code.cloudfoundry.org/lager"
	orgv1 "code.cloudfoundry.org/org-controller/pkg/apis/org/v1"
	"github.com/pkg/errors"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"
)

const orgLabel = "code.cloudfoundry.org/org"

type Org struct {
	logger         lager.Logger
	client         client.Client
	clusterClients map[string]client.Client
}

func NewOrg(
	logger lager.Logger,
	client client.Client,
	clusterClients map[string]client.Client) *Org {
	return &Org{
		logger:         logger,
		client:         client,
		clusterClients: clusterClients,
	}
}

func (r *Org) Reconcile(ctx context.Context, request reconcile.Request) (reconcile.Result, error) {
	logger := r.logger.Session("reconcile-org",
		lager.Data{
			"name":      request.Name,
			"namespace": request.Namespace,
		})

	org := &orgv1.Org{}

	err := r.client.Get(ctx, request.NamespacedName, org)
	if err != nil {
		if apierrors.IsNotFound(err) {
			err := r.reconcileDeletedOrg(logger, ctx, request.Name)
			if err != nil {
				return reconcile.Result{}, fmt.Errorf("failed to reconcile deleted org: %v", err)
			}

			return reconcile.Result{}, nil
		}

		logger.Error("failed-to-get-org", err)

		return reconcile.Result{}, errors.Wrap(err, "failed to get org")
	}

	for _, space := range org.Spec.Spaces {
		clusterClient, ok := r.clusterClients[space.ClusterName]
		if !ok {
			return reconcile.Result{}, fmt.Errorf("unknown cluster context: %q", space.ClusterName)
		}

		nsLogger := logger.Session("reconcile namespace", lager.Data{"org": org.Name, "cluster": space.ClusterName})
		err = r.reconcileSpace(nsLogger, ctx, clusterClient, org, space)
		if err != nil {
			logger.Error("failed-to-reconcile", err)
		}
	}

	return reconcile.Result{}, err
}

func (r *Org) reconcileSpace(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	org *orgv1.Org,
	space orgv1.Space) error {

	namespace := org.Name + "-" + space.Name
	err := createNamespace(logger, ctx, cl, org, namespace)
	if err != nil {
		return err
	}

	users := []orgv1.User{}
	users = append(users, org.Spec.Users...)
	users = append(users, space.Users...)
	err = createRoleBindings(logger, ctx, cl, users, namespace)
	if err != nil {
		return err
	}

	return nil
}

func (r *Org) reconcileDeletedOrg(logger lager.Logger, ctx context.Context, orgName string) error {
	for _, cl := range r.clusterClients {
		err := cl.DeleteAllOf(ctx, &corev1.Namespace{}, client.MatchingLabels{orgLabel: orgName})
		if err != nil {
			return fmt.Errorf("failed to delete namespaces for org: %q %v", orgName, err)
		}
	}

	return nil
}

func createNamespace(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	org *orgv1.Org,
	namespace string) error {

	ns := &corev1.Namespace{
		ObjectMeta: metav1.ObjectMeta{
			Labels: map[string]string{
				orgLabel: org.Name,
			},
			Name: namespace,
		},
	}

	err := cl.Create(ctx, ns)
	if apierrors.IsAlreadyExists(err) {
		logger.Info("namespace already exists", lager.Data{"namespace": namespace})
		return nil
	}
	if err != nil {
		return fmt.Errorf("failed to create namespace: %v", err)
	}
	logger.Info("created namespace", lager.Data{"namespace": namespace})

	return nil
}

func createRoleBindings(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	users []orgv1.User,
	namespace string) error {

	for _, user := range users {
		for _, role := range user.Roles {
			roleBinding := &rbacv1.RoleBinding{
				ObjectMeta: metav1.ObjectMeta{
					Namespace: namespace,
					Name:      fmt.Sprintf("%s-%s", user.Name, role),
				},
				Subjects: []rbacv1.Subject{
					{
						APIGroup: "rbac.authorization.k8s.io",
						Kind:     "User",
						Name:     user.Name,
					},
				},
				RoleRef: rbacv1.RoleRef{
					APIGroup: "rbac.authorization.k8s.io",
					Kind:     "ClusterRole",
					Name:     role,
				},
			}
			if err := cl.Create(ctx, roleBinding); err != nil {
				return fmt.Errorf("failed to create role binding: %v", err)
			}
			logger.Info("created rolebinding", lager.Data{"namespace": namespace, "user": user.Name, "role": role})
		}
	}

	return nil
}
