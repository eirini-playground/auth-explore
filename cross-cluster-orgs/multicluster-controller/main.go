package main

import (
	"context"
	"log"

	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/sample-controller/pkg/signals"

	clusterpkg "admiralty.io/multicluster-controller/pkg/cluster"
	controllerpkg "admiralty.io/multicluster-controller/pkg/controller"
	managerpkg "admiralty.io/multicluster-controller/pkg/manager"
	reconcilepkg "admiralty.io/multicluster-controller/pkg/reconcile"
)

func main() {
	stopCh := signals.SetupSignalHandler()
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		<-stopCh
		cancel()
	}()

	controller := controllerpkg.New(&reconciler{}, controllerpkg.Options{})

	cfg, err := clientcmd.BuildConfigFromFlags("", "/etc/kubeconfig/config")
	if err != nil {
		log.Fatal(err)
	}

	clusterNames := [2]string{"cross-org-1", "cross-org-2"}
	for _, clusterName := range clusterNames {
		cluster := clusterpkg.New(clusterName, cfg, clusterpkg.Options{})
		if err := controller.WatchResourceReconcileObject(ctx, cluster, &v1.Pod{}, controllerpkg.WatchOptions{}); err != nil {
			log.Fatal(err)
		}
	}

	manager := managerpkg.New()
	manager.AddController(controller)

	if err := manager.Start(stopCh); err != nil {
		log.Fatal(err)
	}
}

type reconciler struct{}

func (r *reconciler) Reconcile(req reconcilepkg.Request) (reconcilepkg.Result, error) {
	log.Printf("%s / %s / %s", req.Context, req.Namespace, req.Name)
	return reconcilepkg.Result{}, nil
}
