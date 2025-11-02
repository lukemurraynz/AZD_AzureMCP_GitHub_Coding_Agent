# New Zealand Azure Resource Groups and Storage Accounts

This infrastructure deployment creates Azure Resource Groups based on main cities of New Zealand, with a storage account in each resource group following Azure best practice naming conventions.

## Naming Conventions

This deployment follows the [Azure Cloud Adoption Framework naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming).

### Resource Group Naming Convention

**Format**: `rg-<city>-<environment>-<region>-<instance>`

**Example**: `rg-auckland-prod-australiaeast-001`

- **Prefix**: `rg-` (Resource Group abbreviation)
- **City**: New Zealand city name (lowercase)
- **Environment**: `prod`, `dev`, or `test`
- **Region**: Azure region (e.g., `australiaeast`)
- **Instance**: Three-digit instance number (e.g., `001`)

### Storage Account Naming Convention

**Format**: `st<cityabbrev><environment><instance>`

**Example**: `stakl prod001`

- **Prefix**: `st` (Storage Account abbreviation)
- **City Abbreviation**: 3-letter code for the city (e.g., `akl` for Auckland)
- **Environment**: `prod`, `dev`, or `test`
- **Instance**: Three-digit instance number (e.g., `001`)

**City Abbreviations Mapping**:
- Auckland → `akl`
- Wellington → `wlg`
- Christchurch → `chc`
- Hamilton → `hlt`
- Tauranga → `trg`
- Napier → `npr`
- Dunedin → `dud`
- Palmerston North → `pmr`
- Nelson → `nsn`
- Rotorua → `rot`

**Constraints**:
- 3-24 characters total (abbreviations ensure we stay within this limit)
- Lowercase letters and numbers only
- Must be globally unique across Azure
- No hyphens, underscores, or special characters

## New Zealand Cities Included

The following main cities of New Zealand are included in this deployment:

1. **Auckland** - Largest city and economic hub
2. **Wellington** - Capital city
3. **Christchurch** - Largest city in South Island
4. **Hamilton** - Fourth largest city
5. **Tauranga** - Bay of Plenty coastal city
6. **Napier** - Hawke's Bay city
7. **Dunedin** - Southern city
8. **Palmerston North** - Manawatū-Whanganui region
9. **Nelson** - Top of the South Island
10. **Rotorua** - Geothermal tourism center

## Deployment Instructions

### Prerequisites

- Azure CLI installed
- Azure subscription with appropriate permissions
- Bicep CLI (included with Azure CLI)

### Option 1: Deploy using Azure CLI

```bash
# Login to Azure
az login

# Set your subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Deploy the Bicep template at subscription scope
az deployment sub create \
  --name nz-resources-deployment \
  --location australiaeast \
  --template-file infra/nz-resource-groups.bicep \
  --parameters location=australiaeast environment=prod
```

### Option 2: Preview deployment (What-If)

Before deploying, you can preview what changes will be made:

```bash
az deployment sub what-if \
  --name nz-resources-deployment \
  --location australiaeast \
  --template-file infra/nz-resource-groups.bicep \
  --parameters location=australiaeast environment=prod
```

### Option 3: Deploy to a different environment

```bash
# Deploy to development environment
az deployment sub create \
  --name nz-resources-dev-deployment \
  --location australiaeast \
  --template-file infra/nz-resource-groups.bicep \
  --parameters location=australiaeast environment=dev
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `australiaeast` | The Azure region where resources will be deployed |
| `environment` | string | `prod` | Environment name (prod, dev, test) |

## Resources Created

For each city, the following resources are created:

1. **Resource Group**: Named according to the convention `rg-<city>-<environment>-<region>-001`
2. **Storage Account**: Named according to the convention `st<city><environment>001`

### Storage Account Configuration

The storage accounts are configured with the following best practices:

- **SKU**: Standard_LRS (Locally Redundant Storage)
- **Kind**: StorageV2 (General-purpose v2)
- **HTTPS Only**: Enabled
- **Minimum TLS Version**: TLS 1.2
- **Blob Public Access**: Disabled
- **Encryption**: Enabled for blob and file services
- **Network Access**: Default allow (consider restricting for production)

## Tags Applied

All resources are tagged with:

- **Environment**: The deployment environment (prod/dev/test)
- **City**: The New Zealand city name
- **Country**: NewZealand
- **ManagedBy**: Bicep
- **Purpose**: Descriptive purpose of the resource

## Outputs

The deployment provides the following outputs:

- `resourceGroupNames`: Array of all created resource group names
- `storageAccountNames`: Array of all created storage account names

## Clean Up

To remove all resources created by this deployment:

```bash
# Delete all resource groups (this will also delete all resources within them)
az deployment sub show --name nz-resources-deployment --query 'properties.outputs.resourceGroupNames.value[]' -o tsv | \
  xargs -I {} az group delete --name {} --yes --no-wait
```

## Security Considerations

- Storage accounts are configured with HTTPS-only traffic
- Minimum TLS version is set to 1.2
- Blob public access is disabled by default
- Consider implementing network restrictions for production workloads
- Consider enabling Azure Defender for Storage for advanced threat protection
- Review and adjust access control based on your organization's security policies

## Cost Optimization

- Storage accounts are configured with Standard_LRS for cost efficiency
- Consider implementing lifecycle management policies to optimize storage costs
- Review and adjust redundancy options based on your data durability requirements
- Monitor storage usage and costs using Azure Cost Management

## References

- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Storage Account Naming Rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage)
- [Azure Storage Security Guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)
