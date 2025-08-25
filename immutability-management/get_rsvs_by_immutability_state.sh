#!/bin/bash

get_rsvs_by_immutability_state() {
  local subscription_id="$1"
  local state_filter_csv="$2"
  local output_format="${3:-table}"

  # Validate state_filter_csv parameter
  local valid_states=("null" "Disabled" "Unlocked" "Locked")
  IFS=',' read -ra states <<< "$state_filter_csv"
  for state in "${states[@]}"; do
    if [[ ! " ${valid_states[*]} " =~ " $state " ]]; then
      echo "Error: Invalid state '$state' in state_filter_csv."
      echo "Supported values are: ${valid_states[*]}."
      return 1
    fi
  done

  # Check / install required AZ CLI extensions
  local required_extensions=("resource-graph")
  for ext in "${required_extensions[@]}"; do
    if ! az extension show --name "$ext" &>/dev/null; then
      echo "Installing missing AZ CLI extension: $ext"
      az extension add --name "$ext" --only-show-errors
    fi
  done

  # Parse input CSV into array
  IFS=',' read -ra states <<< "$state_filter_csv"

  local include_null=false
  local values=()

  for state in "${states[@]}"; do
    if [[ "$state" == "null" ]]; then
      include_null=true
    else
      values+=("\"$state\"")
    fi
  done

  # Join values with comma
  local joined_states=""
  if [ "${#values[@]}" -gt 0 ]; then
    joined_states=$(IFS=, ; echo "${values[*]}")
  fi

  # Construct state filter
  local state_filter=""
  if $include_null && [ -n "$joined_states" ]; then
    state_filter="isnull(immutabilityState) or immutabilityState in ($joined_states)"
  elif $include_null; then
    state_filter="isnull(immutabilityState)"
  else
    state_filter="immutabilityState in ($joined_states)"
  fi

  #echo "Running query with immutability filter: $state_filter"
  #echo "Filtering by subscription: $subscription_id"

  az graph query -q "
resources
| where type == 'microsoft.recoveryservices/vaults' and subscriptionId == '$subscription_id'
| extend immutabilityState = properties.securitySettings.immutabilitySettings.state
| where $state_filter
| project name, resourceGroup, subscriptionId, location, immutabilityState
" --first 1000 --query "data[]" --output "$output_format"
}
