package reconcilers

import (
	"context"
	"fmt"

	"code.cloudfoundry.org/lager"
	orgv1 "code.cloudfoundry.org/org-controller/pkg/apis/org/v1"
	orgscheme "code.cloudfoundry.org/org-controller/pkg/generated/clientset/versioned/scheme"
	"github.com/pkg/errors"
	corev1 "k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"
)

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
			logger.Info("org-not-found")

			return reconcile.Result{}, nil
		}

		logger.Error("failed-to-get-org", err)

		return reconcile.Result{}, errors.Wrap(err, "failed to get lrp")
	}

	for _, namespace := range org.Spec.Namespaces {
		clusterClient, ok := r.clusterClients[namespace.ClusterContext]
		if !ok {
			return reconcile.Result{}, fmt.Errorf("unknown cluster context: %q", namespace.ClusterContext)
		}

		err = r.reconcileNamespace(logger, ctx, clusterClient, org, namespace)
		if err != nil {
			logger.Error("failed-to-reconcile", err)
		}
	}

	return reconcile.Result{}, err
}

func (r *Org) reconcileNamespace(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	org *orgv1.Org,
	orgNs orgv1.OrgNamespace) error {

	ns := &corev1.Namespace{
		ObjectMeta: metav1.ObjectMeta{
			Name: orgNs.Namespace,
		},
	}

	err := ctrl.SetControllerReference(org, ns, orgscheme.Scheme)
	if err != nil {
		return err
	}

	err = cl.Create(ctx, ns)
	if apierrors.IsAlreadyExists(err) {
		logger.Info("namespace already exists", lager.Data{"clusterContext": orgNs.ClusterContext, "namespace": orgNs.Namespace})
		return nil
	}
	logger.Info("created namespace", lager.Data{"clusterContext": orgNs.ClusterContext, "namespace": orgNs.Namespace})

	return err
}

func (r *Org) clientForClusterContext(clusterContext string) {}
