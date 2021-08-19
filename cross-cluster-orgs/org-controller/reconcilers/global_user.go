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
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"
)

const (
	roleLevelLabel   = "code.cloudfoundry.org/role_level"
	globalLevel      = "global"
	otherLevel       = "other"
	SubjectNameIndex = ".index.subjectname"
)

type GlobalUser struct {
	logger         lager.Logger
	client         client.Client
	clusterClients map[string]client.Client
}

func NewGlobalUser(
	logger lager.Logger,
	client client.Client,
	clusterClients map[string]client.Client) *GlobalUser {
	return &GlobalUser{
		logger:         logger,
		client:         client,
		clusterClients: clusterClients,
	}
}

func (r *GlobalUser) Reconcile(ctx context.Context, request reconcile.Request) (reconcile.Result, error) {
	logger := r.logger.Session("reconcile-global-user",
		lager.Data{
			"name":      request.Name,
			"namespace": request.Namespace,
		})

	globalUser := &orgv1.GlobalUser{}

	err := r.client.Get(ctx, request.NamespacedName, globalUser)
	if err != nil {
		if apierrors.IsNotFound(err) {
			err := r.reconcileDeletedGlobalUser(logger, ctx, request.Name)
			if err != nil {
				return reconcile.Result{}, fmt.Errorf("failed to reconcile deleted global user: %v", err)
			}

			return reconcile.Result{}, nil
		}

		logger.Error("failed-to-get-global-user", err)

		return reconcile.Result{}, errors.Wrap(err, "failed to get global user")
	}

	for _, clusterClient := range r.clusterClients {
		cfNamespaces, err := r.getCfNamespaces(ctx, clusterClient)
		if err != nil {
			return reconcile.Result{}, errors.Wrap(err, "failed to get cf namespaces")
		}

		for _, cfNs := range cfNamespaces {
			err := r.reconcileGlobalUserInNamespace(logger, ctx, clusterClient, cfNs, globalUser)
			if err != nil {
				return reconcile.Result{}, errors.Wrap(err, fmt.Sprintf("failed to reconcile global user %q in namespace %q", globalUser.Name, cfNs))
			}
		}
	}

	return reconcile.Result{}, err
}

func (r *GlobalUser) reconcileDeletedGlobalUser(logger lager.Logger, ctx context.Context, globalUserName string) error {
	for _, cl := range r.clusterClients {
		roleBindings := &rbacv1.RoleBindingList{}
		err := cl.List(ctx, roleBindings,
			client.MatchingLabels{roleLevelLabel: globalLevel},
			client.MatchingFields{SubjectNameIndex: globalUserName},
		)
		if err != nil {
			return fmt.Errorf("failed to list role bindings: %w", err)
		}

		for _, roleBinding := range roleBindings.Items {
			err = cl.Delete(ctx, &roleBinding)
			if err != nil {
				return fmt.Errorf("failed to delete rolebinding %s::%s: %w", roleBinding.Namespace, roleBinding.Name, err)
			}
		}

	}

	return nil
}

func (r *GlobalUser) reconcileGlobalUserInNamespace(logger lager.Logger, ctx context.Context, cl client.Client, cfNs string, globalUser *orgv1.GlobalUser) error {
	user := orgv1.User{
		Name:  globalUser.Name,
		Roles: globalUser.Spec.Roles,
	}

	return createRoleBindings(logger, ctx, cl, []orgv1.User{user}, globalLevel, cfNs)
}

func (r *GlobalUser) getCfNamespaces(ctx context.Context, cl client.Client) ([]string, error) {
	nsList := &corev1.NamespaceList{}
	if err := cl.List(ctx, nsList, client.HasLabels{orgLabel}); err != nil {
		return nil, err
	}

	namespaces := []string{}
	for _, ns := range nsList.Items {
		namespaces = append(namespaces, ns.Name)
	}
	return namespaces, nil
}
