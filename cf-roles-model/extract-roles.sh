#!/bin/bash

IFS=$'\n'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

for resource in $HOME/workspace/cloud_controller_ng/docs/v3/source/includes/resources/*; do
  if [[ -f "$resource" ]]; then
    continue
  fi
  pushd "$resource" >/dev/null
  {
    resource_name=$(grep "## " _header.md* | head -1 | tr -d "#" | xargs echo)

    for action in *; do
      if ! grep -i -q "Permitted roles" "$action"; then
        continue
      fi
      action_name=$(grep "### " $action | head -1 | tr -d "#" | xargs echo)

      roles=$(awk -f "$SCRIPT_DIR/parse-roles.awk" "$action")

      for role in $roles; do
        echo "$resource_name|$action_name|$role|"
      done

    done
  }
  popd >/dev/null

done
