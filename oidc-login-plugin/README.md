## OIDC login with the cf cli

This dir contains a cf cli plugin that implements the oidc authorization code flow for the cf cli.
Here is a short guide on how to set everthing up

### Clone all relevant repos

It is important to also checkout the relevant branches containing all necessary modifications of
the cli, shim, etc. You can do that by executing:

```
cd ~/workspace
git clone git@github.com:eirini-forks/cli.git
(cd cli && git checkout wip-oidc)
git clone git@github.com:cloudfoundry/cf-crd-explorations.git
(cd cf-crd-explorations && git checkout wip-auth)
git clone git@github.com:eirini-playground/auth-explore.git
```

### Install the modified cf cli

The cf cli has been slightly modified in order to make sense out of the JWT tokens issued by the OIDC
provider (in our case this is dex, that delegates to github). It turns out that the claims that CF uses
today are quite different than the OIDC ones. Look at the diff of wip-oidc for more info.

```
cd ~/workspace/cli/
make build
cp ./out/cf /usr/bin/cf
```

### Install the oidc-login plugin for the cf cli

This is an alternative to the cf login command. It will retrieve the OIDC token and will write it to the
cf config.

First build the plugin...

```
cd ~/workspace/auth-explore/oidc-login-plugin
go build .
```

...then install it

```
cf install-plugin -f ~/workspace/auth-explore/oidc-login-plugin/oidc-login-plugin
```

### Install & configure dex (the OIDC provider)

For non-PKCE, please follow [this guide](../dex-auth/README.md)
For PKCE or Implicit, please follow [this guide](../dex-auth-public-client/README.md)

### Run the modified cf on k8s shim

We have modified the cf shim slightly. You can inspect the diff of the wip-auth branch to see how, but
in short:

- the shim now reads the oidc token from the authorization header and feeds it to the k8s client config
- we have added dummy handlers for `/`, `/v3/organizations` and `/v3/spaces` so that the cli can populate
  the cf config and no manual editing is required.

You can run the shim by executing:

```
cd ~/workspace/cf-crd-explorations
make install
make run
```

### Target the shim and use it

We are ready to go through the OIDC auth flow now.

```
cf target http://localhost:9000
```

For non-pkce flow:

```
cf oidc-login --client-id example-app --client-secret=<dex-client-secret> --issuer https://dex.vcap.me:32000 --issuer-root-ca ~/workspace/auth-explore/dex-auth-public-client/ssl/ca.pem
```

For pkce flow:

```
cf oidc-login --client-id cf-cli --issuer https://dex.vcap.me:32000 --issuer-root-ca ~/workspace/auth-explore/dex-auth-public-client/ssl/ca.pem
```

For implicit flow:

```
cf oidc-login --client-id cf-cli --implicit --issuer https://dex.vcap.me:32000 --issuer-root-ca ~/workspace/auth-explore/dex-auth-public-client/ssl/ca.pem
```

Don't worry about the ca.pem. If you followed everything so far it should have been generated in the expected location.
All you have to do is paste the link from the terminal into a browser and clist `Log in with GitHub`. Then you
should see a message telling you that authentication was successful and the token should have appeared in your cf cli
config. You are logged in!

Now let's list the apps:

```
cf apps
```

At this point you should see an error telling you that you are not authorized to list apps. This is normal and means that
your oidc user has no permissions to list apps. You can grant yourself permissions by running:

```
kubectl create clusterrolebinding <your-username>-app-viewer --clusterrole=app-viewer-role --user=oidc:<your-username>
```

At this point `cf apps` should let you in and show you the list of apps (possibly empty)
