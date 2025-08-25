# RSV Immutability Configuration Functions (bash + az cli)

Scripts to check and set desired immutability state for RSVs within specific Azure subscription.  
KQL is used to get RSVs of specified state as it is the fastest way to get a list of target resources.

**NOTE**: Currently, Contributor rights are required to see Immutability settings in the Azure Portal UI. If you use time-bound Contributor assignments, the Contributor assignment should be active to see immutability settings in the UI. However, KQL, CLI tools, and resource JSON allow you to see the setting without Contributor rights.

---

## **Prerequisites**

1. **Azure CLI Version**:
   - Azure CLI version **2.54.0** or higher is required.
   - To check your Azure CLI version:
     ```bash
     az version
     ```
   - If your version is lower than 2.54.0, update Azure CLI:
     [Azure CLI Installation Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

2. **Azure CLI Extensions**:
   - The `resource-graph` extension is required for querying Recovery Services Vaults.
   - To check if the extension is installed:
     ```bash
     az extension show --name resource-graph
     ```
   - To install the extension:
     ```bash
     az extension add --name resource-graph
     ```

---

## **Create Test Infrastructure Scripts**

- **test-infra-config.sh**: Configuration for creating a specific number of RSVs in a specific subscription with different Immutability settings.
- **test-infra-create.sh**: Creates RSVs as per `test-infra-config.sh`.
- **test-infra-destroy.sh**: Destroys the created test infrastructure.

---

## **get_rsvs_by_immutability_state**

Returns RSVs from a specific subscription with specified Immutability states using KQL in the desired output format.  

### **Possible Immutability States**:
- `null` (when the setting was never configured)
- `Unlocked`
- `Disabled`
- `Locked`

### **Possible Output Formats**:
- `json`
- `table`
- `jsonc`
- `tsv`
- `yaml`
- `yamlc`

To be consumed by the **set_immutability_for_vaults** function, the output of **get_rsvs_by_immutability_state** should be set to `json`.

### **Usage**:
```bash
# Define an array of states
states=("null" "Unlocked" "Disabled" "Locked")

# Call the function
get_rsvs_by_immutability_state "$sub" states "json"
