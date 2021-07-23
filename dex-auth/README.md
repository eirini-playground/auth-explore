## Create a kind cluster with dex authentication via GitHub

- [Register](https://github.com/settings/applications/new) the example app in github to obtain a client id and a secret as follows:
  - Application Name: `example-app`
  - Homepage URL: `http://127.0.0.1:5555/`
  - Authorization callback URL: `https://dex.vcap.me:32000/callback`
- Run `export CLIENT_ID=<client-id> export CLIENT_SECRET=<client-secret> export USERNAME=<your-github-username>; ./deploy.sh`. Fill in secrets from previous step.
- Run the [example app](https://github.com/dexidp/dex/tree/master/examples/example-app)
  - Build it by running `go install .`
  - Run it:

```
./example-app --issuer https://dex.vcap.me:32000 --issuer-root-ca "$HOME/workspace/auth-explore/dex-auth/ssl/ca.pem"
```

- From your local machine run the following command (in order to export some ports from the gcp machine to localhost)

```
ssh -L 5555:127.0.0.1:5555 -L 32000:127.0.0.1:32000 <your-user>@<your-machine-host>
```

- Open a browser and go to localhost:5555
- Do not fill in the form, just click login
- Choose Github Authentication and fill in your credentials
- You should get a response page with a token
- Add the `ID Token` from the previous step to your kube config

```
users:
- name: (USERNAME)
  user:
    token: (ID-TOKEN)
```

- Try to get pods in the `default` namespace. It should work (the deploy.sh creates a role for that)

```
kubectl --user <your-github-user> get pods -n default
```

- Try to get pods in a non-default namespace. It should not work.

```
kubectl --user <your-github-user> get pods -n dex
```
