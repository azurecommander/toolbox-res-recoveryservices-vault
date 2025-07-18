#!/bin/bash

get_rsvs_by_immutability_state() {
  local subscription_id="$1"
  local state_filter_csv="$2"
  local output_format="${3:-table}"

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