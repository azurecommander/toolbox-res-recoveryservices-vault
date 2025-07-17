# RSV Immutability Condiguration Functions (bash + az cli)

Scripts to check and set desired immutability state for RSVs within specific Azure subscription.
KQL is used to get RSVs of specified state as it is fastest way to get a list of target resources.

NOTE: Currently Contributor rights are required to see Immutability settings in Azure Portal UI - if you use time-bound Contributor assignments, Contributor assignment should be active to see immutability settings in UI, but KQL, CLI tools and resource JSON allow you to see the setting without Contributor rights.

## Create test infra scripts

test-infra-config.sh  - configuration for creating a specific number of RSVs in specific subscription with different Immutability settings
test-infra-create.sh  - create RSVs as per test-infra-config.sh
test-infra-destroy.sh - destroy created test infra

## get_rsvs_by_immutability_state

Returns RSVs from specific subscription with specified Immutability states through KQL in desired output format.
Possible immutability states: null (wnen setting was never configured), Unlocked, Disabled, Locked
Possible output formats: json, table, jsonc, tsv, yaml, yamlc

To be consumed by **set_immutability_for_vaults** function output of **get_rsvs_by_immutability_state** should be set to json.

```Bash
get_rsvs_by_immutability_state "$sub" "null,Unlocked,Disabled,Locked" "json"
```

## set_immutability_for_vaults

Sets specified immutability setting on all vaults returned by **get_rsvs_by_immutability_state** function, you pass in output of this function along with desired immutability state and target subscrioption.

```Bash
set_immutability_for_vaults "$(get_rsvs_by_immutability_state "$sub" "null,Disabled" json)" "Unlocked" "$sub"
```

## sample-function-calls

Just sample file with functions calls.
