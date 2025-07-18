resource_group="test-rg"
location="spaincentral"
sub="SUB_ID"

declare -A vault_immutability_map

# Define name → setting
vault_immutability_map=(
  ["vault1"]=""
  ["vault2"]="Disabled"
  ["vault3"]="Unlocked"
  ["vault4"]="Locked"
)