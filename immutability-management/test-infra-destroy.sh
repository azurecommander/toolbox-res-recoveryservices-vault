#!/bin/bash

# Load vault names and common config
source "$(dirname "$0")/test-infra-config.sh"

for vault in "${!vault_immutability_map[@]}"; do
  echo "Deleting vault: $vault"

  az backup vault delete \
    --name "$vault" \
    --resource-group "$resource_group" \
    --subscription "$sub" \
    --yes
done