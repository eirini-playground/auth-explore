#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

terraform -chdir="$SCRIPT_DIR/terraform" init -backend-config="prefix=terraform/state/dex-pinniped" -upgrade=true
terraform -chdir="$SCRIPT_DIR/terraform" destroy -auto-approve
