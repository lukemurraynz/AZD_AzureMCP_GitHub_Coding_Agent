# AZD_AzureMCP_GitHub_Coding_Agent

Azure Developer CLI Coding Agent repo. Used for testing functionality.

## New Zealand Azure Resource Groups

This repository contains Infrastructure as Code (IaC) for deploying Azure Resource Groups and Storage Accounts based on the main cities of New Zealand.

### Quick Start

```bash
# Validate the Bicep templates
./infra/test-templates.sh

# Preview the deployment
az deployment sub what-if \
  --location australiaeast \
  --template-file infra/nz-resource-groups.bicep \
  --parameters environment=prod

# Deploy the infrastructure
./infra/deploy.sh
```

### What's Included

- **10 Resource Groups** - One for each main NZ city (Auckland, Wellington, Christchurch, Hamilton, Tauranga, Napier, Dunedin, Palmerston North, Nelson, Rotorua)
- **10 Storage Accounts** - One in each resource group
- **Azure Best Practice Naming Conventions** - Following Cloud Adoption Framework guidelines
- **Security Best Practices** - HTTPS-only, TLS 1.2, encryption enabled
- **Comprehensive Testing** - Automated validation suite

### Documentation

See [infra/README.md](infra/README.md) for complete documentation, naming conventions, and deployment instructions.

### Naming Conventions

- **Resource Groups**: `rg-<city>-<environment>-<region>-001`
  - Example: `rg-auckland-prod-australiaeast-001`
  
- **Storage Accounts**: `st<cityabbrev><environment>001`
  - Example: `staklprod001` (Auckland)
  - City abbreviations: akl, wlg, chc, hlt, trg, npr, dud, pmr, nsn, rot
