package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"runtime/pprof"
	"time"

	workloadsv1alpha1 "code.cloudfoundry.org/cf-k8s-controllers/api/v1alpha1"
	"code.cloudfoundry.org/lager"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"sigs.k8s.io/controller-runtime/pkg/cache"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/cluster"
)

func main() {
	logger := lager.NewLogger("cache-lister")
	logger.RegisterSink(lager.NewPrettySink(os.Stdout, lager.DEBUG))

	if err := workloadsv1alpha1.AddToScheme(scheme.Scheme); err != nil {
		exitf("failed to add the org scheme to the ORG CRD scheme: %v", err)
	}

	kubeConfigPath := filepath.Join(os.Getenv("HOME"), ".kube/config")
	kubeConfig, err := clientcmd.BuildConfigFromFlags("", kubeConfigPath)
	exitfIfError(err, "Failed to build kubeconfig")

	clusterOptions := func(opts *cluster.Options) {
		opts.Scheme = scheme.Scheme
	}

	cacheCluster, err := cluster.New(kubeConfig, clusterOptions)
	exitfIfError(err, "Failed to create controller-runtime cluster")

	clusterCache := cacheCluster.GetCache()
	go func() {
		err := clusterCache.Start(context.Background())
		if err != nil {
			logger.Error("failed to start cache", err)
		}
	}()

	clusterCache.WaitForCacheSync(context.Background())

	client := cacheCluster.GetClient()

	// err = populateCluster(logger, client)
	exitfIfError(err, "Failed to populate cluster")

	err = performListings(logger, client)
	exitfIfError(err, "failed to perform listing")
	err = exec.Command("kubectl", "apply", "-f", "app.yaml").Run()
	exitfIfError(err, "failed to create an app")

	kubeConfig.Impersonate = rest.ImpersonationConfig{
		UserName: "alice",
	}
	clusterOptions = func(opts *cluster.Options) {
		opts.Scheme = scheme.Scheme
		opts.NewCache = func(config *rest.Config, opts cache.Options) (cache.Cache, error) {
			return clusterCache, nil
		}
	}
	clientCluster, err := cluster.New(kubeConfig, clusterOptions)
	exitfIfError(err, "Failed to create controller-runtime cluster")
	client = clientCluster.GetClient()

	err = performListings(logger, client)
	exitfIfError(err, "failed to perform listing")
	err = performListings(logger, client)
	exitfIfError(err, "failed to perform listing")

	f, _ := os.Create("/tmp/profile.pb.gz")
	defer f.Close()
	runtime.GC()
	pprof.WriteHeapProfile(f)
}

func populateCluster(log lager.Logger, c client.Client) error {
	ctx := context.Background()

	for i := 1; i <= 100; i++ {
		namespace := fmt.Sprintf("ns-%03d", i)
		ns := &corev1.Namespace{
			ObjectMeta: metav1.ObjectMeta{
				Name: namespace,
			},
		}
		err := c.Create(ctx, ns)
		if err != nil {
			if !errors.IsAlreadyExists(err) {
				return fmt.Errorf("couldn't create namespace: %w", err)
			}
		}

		for j := 1; j <= 10; j++ {
			app := &workloadsv1alpha1.CFApp{
				ObjectMeta: metav1.ObjectMeta{
					Name:      fmt.Sprintf("app-%03d-%03d", i, j),
					Namespace: namespace,
				},
				Spec: workloadsv1alpha1.CFAppSpec{
					Name:         "my-app",
					DesiredState: "STOPPED",
					Lifecycle: workloadsv1alpha1.Lifecycle{
						Type: "buildpack",
					},
				},
			}
			err := c.Create(ctx, app)
			if err != nil {
				if errors.IsAlreadyExists(err) {
					continue
				}
				return fmt.Errorf("couldn't create app: %w", err)
			}
		}
		log.Info("created apps for namespace", lager.Data{"ns": i})
	}

	return nil
}

func performListings(log lager.Logger, c client.Client) error {
	ctx := context.Background()

	apps := []workloadsv1alpha1.CFApp{}

	start := time.Now()
	for i := 1; i <= 100; i++ {
		namespace := fmt.Sprintf("ns-%03d", i)
		list := &workloadsv1alpha1.CFAppList{}
		err := c.List(ctx, list, client.InNamespace(namespace))
		if err != nil {
			return fmt.Errorf("couldn't list apps: %w", err)
		}

		apps = append(apps, list.Items...)
	}
	elapsed := time.Since(start)
	fmt.Printf("elapsed = %+v\n", elapsed)
	fmt.Println("")

	_ = apps
	fmt.Printf("len(ap = %+v\n", len(apps))

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
