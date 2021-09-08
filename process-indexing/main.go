package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"code.cloudfoundry.org/lager"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/cluster"
)

func main() {
	logger := lager.NewLogger("cache-lister")
	logger.RegisterSink(lager.NewPrettySink(os.Stdout, lager.DEBUG))

	kubeConfigPath := filepath.Join(os.Getenv("HOME"), ".kube/config")
	kubeConfig, err := clientcmd.BuildConfigFromFlags("", kubeConfigPath)
	exitfIfError(err, "Failed to build kubeconfig")

	cacheCluster, err := cluster.New(kubeConfig)
	exitfIfError(err, "Failed to create controller-runtime cluster")

	getProcessGuid := func(obj client.Object) []string {
		pod, _ := obj.(*corev1.Pod)
		processes := []string{}
		for _, container := range pod.Spec.Containers {
			processes = append(processes, container.Name)
		}

		return processes
	}
	cacheCluster.GetFieldIndexer().IndexField(context.Background(), &corev1.Pod{}, ".index.process.guid", getProcessGuid)

	clusterCache := cacheCluster.GetCache()
	go func() {
		err := clusterCache.Start(context.Background())
		if err != nil {
			logger.Error("failed to start cache", err)
		}
	}()
	clusterCache.WaitForCacheSync(context.Background())

	client := cacheCluster.GetClient()
	err = performListings(logger, client)
	exitfIfError(err, "failed to perform listing")
}

func performListings(log lager.Logger, c client.Client) error {
	ctx := context.Background()

	for _, label := range []string{"manager", "kube-rbac-proxy", "arghhh"} {
		pods := &corev1.PodList{}

		err := c.List(ctx, pods, client.InNamespace("hnc-system"), client.MatchingFields{".index.process.guid": label})
		if err != nil {
			return fmt.Errorf("couldn't list pods: %w", err)
		}

		fmt.Printf("#pods = %+v\n", len(pods.Items))
		if len(pods.Items) > 0 {
			fmt.Printf("pods.Items[0].Name = %+v\n", pods.Items[0].Name)
		}
	}

	return nil
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
