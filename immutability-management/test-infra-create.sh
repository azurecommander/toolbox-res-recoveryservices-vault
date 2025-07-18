#!/bin/bash

# Load config and variable definitions
source "$(dirname "$0")/test-infra-config.sh"

# Create test infrastructure
for vault in "${!vault_immutability_map[@]}"; do
  state="${vault_immutability_map[$vault]}"
  echo "Creating vault: $vault"

  # Create the vault
  az backup vault create \
    --name "$vault" \
    --resource-group "$resource_group" \
    --location "$location"

  # Conditionally set immutability only if state is non-empty
if [[ -n "$state" ]]; then
  if [[ "$state" == "Locked" ]]; then
    echo "  Setting immutability to: Unlocked first"
    az backup vault update \
      --name "$vault" \
      --resource-group "$resource_group" \
      --immutability-state Unlocked

    echo "  Now setting immutability to: Locked"
    az backup vault update \
      --name "$vault" \
      --resource-group "$resource_group" \
      --immutability-state Locked
  else
    echo "  Setting immutability to: $state"
    az backup vault update \
      --name "$vault" \
      --resource-group "$resource_group" \
      --immutability-state "$state"
  fi
else
  echo "  Skipping immutability configuration"
fi
done