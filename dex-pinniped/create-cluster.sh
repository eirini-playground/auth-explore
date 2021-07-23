#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

terraform -chdir="$SCRIPT_DIR/terraform" init -backend-config="prefix=terraform/state/dex-pinniped" -upgrade=true
terraform -chdir="$SCRIPT_DIR/terraform" apply -auto-approve

gcloud container clusters get-credentials --zone europe-west1-b --project cff-eirini-peace-pods dex-pinniped
