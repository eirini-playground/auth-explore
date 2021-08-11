package reconcilers

import (
	"context"
	"fmt"

	"code.cloudfoundry.org/lager"
	orgv1 "code.cloudfoundry.org/org-controller/pkg/apis/org/v1"
	"github.com/pkg/errors"
	corev1 "k8s.io/api/core/v1"
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

	for _, cluster := range org.Spec.Clusters {
		clusterClient, ok := r.clusterClients[cluster.Name]
		if !ok {
			return reconcile.Result{}, fmt.Errorf("unknown cluster context: %q", cluster.Name)
		}

		nsLogger := logger.Session("reconcile namespace", lager.Data{"org": org.Name, "cluster": cluster.Name})
		err = r.reconcileNamespaces(nsLogger, ctx, clusterClient, org, cluster.Namespaces)
		if err != nil {
			logger.Error("failed-to-reconcile", err)
		}
	}

	return reconcile.Result{}, err
}

func (r *Org) reconcileNamespaces(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	org *orgv1.Org,
	namespaces []string) error {
	toBeCreated, toBeDeleted, err := analyseNamespaces(ctx, cl, org.Name, namespaces)
	if err != nil {
		return err
	}

	for _, ns := range toBeCreated {
		err := createNamespace(logger, ctx, cl, org, ns)
		if err != nil {
			return err
		}
	}

	for _, ns := range toBeDeleted {
		err := deleteNamespace(logger, ctx, cl, ns)
		if err != nil {
			return err
		}
	}

	return nil
}

func (r *Org) reconcileDeletedOrg(logger lager.Logger, ctx context.Context, orgName string) error {
	for _, cl := range r.clusterClients {
		_, toBeDeleted, err := analyseNamespaces(ctx, cl, orgName, []string{})
		if err != nil {
			return fmt.Errorf("failed to analyse namespaces: %v", err)
		}

		for _, ns := range toBeDeleted {
			err = deleteNamespace(logger, ctx, cl, ns)
			if err != nil {
				return fmt.Errorf("failed to delete namespace: %q %v", ns, err)
			}
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

func deleteNamespace(
	logger lager.Logger,
	ctx context.Context,
	cl client.Client,
	namespace string) error {

	ns := &corev1.Namespace{}
	err := cl.Get(ctx, client.ObjectKey{Name: namespace}, ns)
	if err != nil {
		if apierrors.IsNotFound(err) {
			logger.Info("namespace already deleted", lager.Data{"namespace": namespace})
			return nil
		}
	}

	err = cl.Delete(ctx, ns)
	if err != nil {
		return fmt.Errorf("failed to delete namespace: %v", err)
	}
	logger.Info("deleted namespace", lager.Data{"namespace": namespace})
	return nil
}

func analyseNamespaces(ctx context.Context, clusterClient client.Client, orgName string, desiredNamespaces []string) ([]string /*to be created*/, []string /*to be deleted*/, error) {
	toBeCreated := []string{}
	toBeDeleted := []string{}

	existingNamespacesList := corev1.NamespaceList{}
	err := clusterClient.List(ctx, &existingNamespacesList, client.MatchingLabels{
		orgLabel: orgName,
	})
	if err != nil {
		return nil, nil, fmt.Errorf("failed to list namespaces: %v", err)
	}

	isExisting := map[string]struct{}{}

	for _, ns := range existingNamespacesList.Items {
		isExisting[ns.Name] = struct{}{}
	}

	isDesired := map[string]struct{}{}

	for _, ns := range desiredNamespaces {
		isDesired[ns] = struct{}{}
	}

	for ns := range isExisting {
		if _, desired := isDesired[ns]; !desired {
			toBeDeleted = append(toBeDeleted, ns)
		}
	}

	for ns := range isDesired {
		if _, existing := isExisting[ns]; !existing {
			toBeCreated = append(toBeCreated, ns)
		}
	}

	return toBeCreated, toBeDeleted, nil
}
