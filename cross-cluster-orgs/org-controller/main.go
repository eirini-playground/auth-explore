package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"code.cloudfoundry.org/eirini/util"
	"code.cloudfoundry.org/lager"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
	_ "k8s.io/client-go/plugin/pkg/client/auth"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/builder"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/cluster"
	"sigs.k8s.io/controller-runtime/pkg/manager"

	orgv1 "code.cloudfoundry.org/org-controller/pkg/apis/org/v1"
	orgscheme "code.cloudfoundry.org/org-controller/pkg/generated/clientset/versioned/scheme"
	"code.cloudfoundry.org/org-controller/reconcilers"
	kscheme "k8s.io/client-go/kubernetes/scheme"
	ctrl "sigs.k8s.io/controller-runtime"
)

func main() {
	if err := kscheme.AddToScheme(orgscheme.Scheme); err != nil {
		exitf("failed to add the org scheme to the ORG CRD scheme: %v", err)
	}

	kubeConfig, err := clientcmd.BuildConfigFromFlags("", "")
	exitfIfError(err, "Failed to build kubeconfig")

	exitfIfError(err, "Failed to create k8s runtime client")

	logger := lager.NewLogger("org-controller")
	logger.RegisterSink(lager.NewPrettySink(os.Stdout, lager.DEBUG))

	managerOptions := manager.Options{
		MetricsBindAddress: "0",
		Scheme:             orgscheme.Scheme,
		Namespace:          "org",
		Logger:             util.NewLagerLogr(logger),
		LeaderElection:     true,
		LeaderElectionID:   "org-leader",
	}

	mgr, err := manager.New(kubeConfig, managerOptions)
	exitfIfError(err, "failed to create k8s controller runtime manager")

	clusterClients, err := getClusterClients(logger)
	exitfIfError(err, "failed to create cluster clients")

	orgReconciler := reconcilers.NewOrg(logger, mgr.GetClient(), clusterClients)

	err = builder.
		ControllerManagedBy(mgr).
		For(&orgv1.Org{}).
		Owns(&corev1.Namespace{}).
		Owns(&rbacv1.RoleBinding{}).
		Complete(orgReconciler)
	exitfIfError(err, "Failed to build controller")

	err = mgr.Start(ctrl.SetupSignalHandler())
	exitfIfError(err, "Failed to start manager")
}

func exitIfError(err error) {
	exitfIfError(err, "an unexpected error occurred")
}

func exitfIfError(err error, message string) {
	if err != nil {
		fmt.Fprintln(os.Stderr, fmt.Errorf("%s: %w", message, err))
		os.Exit(1)
	}
}

func exitf(messageFormat string, args ...interface{}) {
	exitIfError(fmt.Errorf(messageFormat, args...))
}

func getClusterClients(logger lager.Logger) (map[string]client.Client, error) {
	clusterNames := []string{"cross-org-1", "cross-org-2"}
	result := map[string]client.Client{}

	for _, clusterName := range clusterNames {
		clusterConfig, err := clientcmd.BuildConfigFromFlags("", filepath.Join("/etc", clusterName, clusterName))
		if err != nil {
			return nil, err
		}

		cluster, err := cluster.New(clusterConfig)
		if err != nil {
			return nil, err
		}
		go func() {
			err := cluster.GetCache().Start(context.Background())
			if err != nil {
				logger.Error("failed to start cache", err, lager.Data{"clusterName": clusterName})
			}
		}()

		result[clusterName] = cluster.GetClient()
	}

	return result, nil
}
