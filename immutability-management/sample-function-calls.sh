# Load config and variable definitions
source "$(dirname "$0")/test-infra-config.sh"

# Source the function definitions from files in the same folder
source "./get_rsvs_by_immutability_state.sh"
source "./set_immutability_for_vaults.sh"

# Sample calls to the functions
sub="your-subscription-id"
states=("null" "Disabled" "Unlocked" "Locked")
get_rsvs_by_immutability_state $sub states json

# Transition specified RSV states to desired state
states=("Unlocked")
set_immutability_for_vaults "$(get_rsvs_by_immutability_state "$sub" states json)" "Disabled" "$sub"
