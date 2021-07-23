#!/bin/bash

set -euo pipefail

uaac target https://172.17.0.1.nip.io --skip-ssl-validation
uaac token client get admin -s client
uaac client add kubernetes --name kubernetes-openid --secret k8s-password --scope openid --authorized_grant_types user_token,password
uaac user add alice -p password --email alice@example.com
uaac token owner get kubernetes alice
