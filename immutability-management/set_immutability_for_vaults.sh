#!/bin/bash

set_immutability_for_vaults() {
  local vaults_json="$1"      # JSON array from get_rsvs_by_immutability_state (raw JSON string)
  local desired_state="$2"    # e.g. "Unlocked", "Locked", "Disabled"
  local sub="$3"              # subscription id (needed for az commands)

  # Function to compare versions
  version_gte() {
    local v1="$1"
    local v2="$2"
    [ "$(printf '%s\n' "$v1" "$v2" | sort -V | head -n 1)" = "$v2" ]
  }

  # Check Azure CLI version
  az_version=$(az version --query '"azure-cli"' -o tsv)
  required_version="2.54.0"

  if ! version_gte "$az_version" "$required_version"; then
    echo "Error: Azure CLI version $required_version or higher is required."
    echo "You have Azure CLI version $az_version installed."
    echo "Please update Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    return 1
  fi

  # Validate desired_state parameter
  if [[ "$desired_state" != "Disabled" && "$desired_state" != "Locked" && "$desired_state" != "Unlocked" ]]; then
    echo "Error: Invalid immutability state '$desired_state'."
    echo "Supported values are: Disabled, Locked, Unlocked."
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed. Please install jq."
    return 1
  fi

  if [[ -z "$sub" ]]; then
    echo "Subscription ID parameter missing."
    return 1
  fi

  # Count number of vaults
  local vault_count
  vault_count=$(echo "$vaults_json" | jq 'length')

  # Confirmation prompt if locking vaults
  if [[ "$desired_state" == "Locked" ]]; then
    RED='\033[1;31m'
    NC='\033[0m' # No Color

    echo -e "${RED}WARNING:${NC}"
    echo -e "${RED}You are about to LOCK $vault_count vault(s) in subscription $sub.${NC}"
    echo -e "${RED}Locking is irreversible!${NC}"
    echo -e "${RED}Type 'continue' to proceed:${NC}"

    read -r user_input
    if [[ "$user_input" != "continue" ]]; then
      echo -e "${NC}Aborted by user."
      return 1
    fi
  fi

  # Iterate vaults
  echo "$vaults_json" | jq -c '.[]' | while read -r vault; do
    local name resource_group

    name=$(echo "$vault" | jq -r '.name')
    resource_group=$(echo "$vault" | jq -r '.resourceGroup')

    echo "Setting immutability state '$desired_state' on vault '$name' in resource group '$resource_group'..."

    az backup vault update \
      --name "$name" \
      --resource-group "$resource_group" \
      --immutability-state "$desired_state" \
      --subscription "$sub" \
      >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
      echo "Updated vault '$name' successfully."
    else
      echo "Failed to update vault '$name'."
    fi
  done
}
