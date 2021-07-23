# CF-for-k8s AuthN / AuthZ Exploration

## Step 1 - Authentication (AuthN)

We can get k8s to authenticate users in various ways:

- client certificates
- tokens matching a list loaded into the API server
- username/password basic auth
- Open ID Connect (OIDC) integration

All but OIDC have major drawbacks.

### Experiment #1

UAA is an OIDC server, so experiment number 1 is to see if we can get k8s authenticating users via UAA.
We are attempting this on Kind initially with UAA running in a pod.

#### Kind

Kind needs to be configured to allow access to UAA externally via https.
So we have enabled nginx ingress in [cluster.yml](cluster.yml).
This config also instructs the API server to use OIDC and points to the external UAA address.

Create the kind cluster with

```
kind create cluster --name uaa-play --config cluster.yml
```

Then enable nginx-ingress using

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

#### UAA

Clone UAA from git@github.com:cloudfoundry/uaa.

We created the CA in the `saml` directory using the following openssl commands

```
openssl genrsa -des3 -out private.key
openssl req -x509 -new -nodes -key private.key -sha256 -days 1024 -out ca.pem
```

The key and cert are included in the `uaa/_values.yml`.

Copy [\_values.yml](uaa/_values.yml) to `k8s/templates/values/` in the uaa repo.
Then run `make apply` from the `k8s` directory to install UAA.
This takes several minutes.

Then apply the ingress rule:

_Note_: There seems to be some validation bug in the latest version of nginx, so we had to delete their validating webhook first:

```
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
```

```
kubectl create secret tls uaa-tls --key uaa/uaa.key --cert uaa/uaa.crt
kubectl apply -f uaa/uaa-ingress.yml
```

The above secrets were created with:

```
cd uaa
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout uaa.key -out uaa.crt -subj "/CN=172.17.0.1.nip.io" -addext "subjectAltName = DNS:172.17.0.1.nip.io"

```

#### UAA Client

Install `uaac`. Use sudo if `gem install` complains.

```
gem install cf-uaac
```

Target and login

```
uaac target https://172.17.0.1.nip.io --skip-ssl-validation
uaac token client get admin -s client
```

And create the client used by kubernetes

```
uaac client add kubernetes --name kubernetes-openid --secret k8s-password --scope openid --authorized_grant_types user_token,password
```

#### Authenticating

Create a user:

```
uaac user add alice -p password --email alice@example.com
```

Get a token in your `~/.uaac.yml`:

```
uaac token owner get kubernetes alice
```

Copy token from `~/.uaac.yml` into `~/.kube/config`. The section should look like:

```
users:
- ...
- name: alice
  user:
    auth-provider:
      name: oidc
      config:
        client-id: kubernetes
        client-secret: k8s-password
        id-token: <id_token from .uaac.yml>
        refresh-token: <refresh_token from .uaac.yml>
        idp-issuer-url: https://172.17.0.1.nip.io/oauth/token
```
