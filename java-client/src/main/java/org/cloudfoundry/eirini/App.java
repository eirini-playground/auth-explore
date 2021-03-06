package org.cloudfoundry.eirini;
import org.cloudfoundry.client.CloudFoundryClient;
import org.cloudfoundry.operations.CloudFoundryOperations;
import org.cloudfoundry.operations.DefaultCloudFoundryOperations;
import org.cloudfoundry.operations.applications.ApplicationSummary;
import org.cloudfoundry.reactor.ConnectionContext;
import org.cloudfoundry.reactor.DefaultConnectionContext;
import org.cloudfoundry.reactor.TokenProvider;
import org.cloudfoundry.reactor.client.ReactorCloudFoundryClient;
import org.cloudfoundry.reactor.tokenprovider.K8sTokenProvider;

public class App
{
    public static void main( String[] args )
    {
        String apiHost = ensureEnv("CF_API_HOST");
        String port = ensureEnv("CF_PORT");
        String secure = ensureEnv("CF_SECURE");
        String org = ensureEnv("CF_ORG");
        String space = ensureEnv("CF_SPACE");

        ConnectionContext connectionContext = DefaultConnectionContext.builder()
            .apiHost(apiHost)
            .port(Integer.parseInt(port))
            .secure(secure.equals("true"))
            .build();

        TokenProvider tokenProvider = K8sTokenProvider.builder().build();

        CloudFoundryClient client = ReactorCloudFoundryClient.builder()
            .connectionContext(connectionContext)
            .tokenProvider(tokenProvider)
            .build();

        CloudFoundryOperations ops = DefaultCloudFoundryOperations.builder()
            .cloudFoundryClient(client)
            .organization(org)
            .space(space)
            .build();

        ops.applications()
            .list()
            .map(ApplicationSummary::getName)
            .subscribe(System.out::println);

    }

    private static String ensureEnv(String name) {
        String val = System.getenv(name);
        if (val == null) {
            System.err.println("Please set $"+name);
            System.exit(1);
        }

        return val;
    }
}

