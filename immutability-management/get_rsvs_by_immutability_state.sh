get_rsvs_by_immutability_state() {
  local subscription_id="$1"
  local -n state_array="$2"  # Use a different name for the local reference
  local output_format="${3:-table}"

  # Define valid states
  local valid_states=("null" "Disabled" "Unlocked" "Locked")

  # Validate states
  for state in "${state_array[@]}"; do
    if [[ ! " ${valid_states[*]} " =~ " $state " ]]; then
      echo "Error: Invalid state '$state'."
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

  # Construct filters
  local include_null=false
  local values=()

  for state in "${state_array[@]}"; do
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
    state_filter="(isnull(immutabilityState) or immutabilityState in ($joined_states))"
  elif $include_null; then
    state_filter="isnull(immutabilityState)"
  elif [ -n "$joined_states" ]; then
    state_filter="immutabilityState in ($joined_states)"
  else
    echo "Error: No valid states provided for filtering."
    return 1
  fi

  # Run the Azure Resource Graph query
  az graph query -q "
resources
| where type == 'microsoft.recoveryservices/vaults' and subscriptionId == '$subscription_id'
| extend immutabilityState = properties.securitySettings.immutabilitySettings.state
| where $state_filter
| project name, resourceGroup, subscriptionId, location, immutabilityState
" --first 1000 --query "data[]" --output "$output_format"
}
