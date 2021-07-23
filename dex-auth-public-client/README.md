## Create a kind cluster with dex authentication via GitHub (PKCE flow or Implicit flow)

This directory contains a similar deployment to the other dex example, the differences being

- [Register](https://github.com/settings/applications/new) the example app in github to obtain a client id and a secret as follows:
  - Application Name: `cf-cli`
  - Homepage URL: `http://127.0.0.1:5555/`
  - Authorization callback URL: `https://dex.vcap.me:32000/callback`
- Run `CLIENT_ID=<client-id> CLIENT_SECRET=<client-secret> ./deploy.sh`. Fill in secrets from previous step.
