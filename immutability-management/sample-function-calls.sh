#!/bin/bash
az config set extension.use_dynamic_install=no --only-show-errors

# Load config and variable definitions
source "$(dirname "$0")/test-infra-config.sh"

# Source the function definitions from files in the same folder
source "$(dirname "$0")/get-rsvs-by-immutability-state.sh"
source "$(dirname "$0")/set-immutability-for-vaults.sh"

# Sample calls to the functions
#get_rsvs_by_immutability_state "$sub" "null,Disabled,Unlocked" "json"
#get_rsvs_by_immutability_state "$sub" "Disabled,Unlocked" json

# Transition specified RSV states to desired state
set_immutability_for_vaults "$(get_rsvs_by_immutability_state "$sub" "Locked" json)" "Disabled" "$sub"
