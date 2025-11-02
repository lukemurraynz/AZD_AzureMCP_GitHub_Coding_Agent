# Azure Resources Summary - New Zealand Cities

## Resources to be Created

This deployment will create **20 Azure resources** across **10 Resource Groups**:

### Resource Groups (10)

Each resource group follows the naming convention: `rg-<city>-prod-newzealandnorth-001`

1. **rg-auckland-prod-newzealandnorth-001**
2. **rg-wellington-prod-newzealandnorth-001**
3. **rg-christchurch-prod-newzealandnorth-001**
4. **rg-hamilton-prod-newzealandnorth-001**
5. **rg-tauranga-prod-newzealandnorth-001**
6. **rg-napier-prod-newzealandnorth-001**
7. **rg-dunedin-prod-newzealandnorth-001**
8. **rg-palmerstonnorth-prod-newzealandnorth-001**
9. **rg-nelson-prod-newzealandnorth-001**
10. **rg-rotorua-prod-newzealandnorth-001**

### Storage Accounts (10)

Each storage account follows the naming convention: `st<cityabbrev>prod001`

| City | Abbreviation | Storage Account Name | Resource Group |
|------|--------------|---------------------|----------------|
| Auckland | akl | **staklprod001** | rg-auckland-prod-newzealandnorth-001 |
| Wellington | wlg | **stwlgprod001** | rg-wellington-prod-newzealandnorth-001 |
| Christchurch | chc | **stchcprod001** | rg-christchurch-prod-newzealandnorth-001 |
| Hamilton | hlt | **sthltprod001** | rg-hamilton-prod-newzealandnorth-001 |
| Tauranga | trg | **sttrgprod001** | rg-tauranga-prod-newzealandnorth-001 |
| Napier | npr | **stnprprod001** | rg-napier-prod-newzealandnorth-001 |
| Dunedin | dud | **stdudprod001** | rg-dunedin-prod-newzealandnorth-001 |
| Palmerston North | pmr | **stpmrprod001** | rg-palmerstonnorth-prod-newzealandnorth-001 |
| Nelson | nsn | **stnsnprod001** | rg-nelson-prod-newzealandnorth-001 |
| Rotorua | rot | **strotprod001** | rg-rotorua-prod-newzealandnorth-001 |

## Resource Configuration

### Storage Account Specifications

- **Type**: General Purpose v2 (StorageV2)
- **Performance**: Standard
- **Replication**: Locally Redundant Storage (LRS)
- **Location**: Australia East (same as resource group)

### Security Configuration

All storage accounts are configured with:
- ✅ HTTPS-only traffic enforcement
- ✅ Minimum TLS version 1.2
- ✅ Blob public access disabled
- ✅ Encryption at rest enabled (blob and file services)
- ✅ Azure Services bypass for network ACLs

### Tags Applied

All resources include the following tags:

| Tag | Value |
|-----|-------|
| Environment | prod |
| City | (respective city name) |
| Country | NewZealand |
| ManagedBy | Bicep |
| Purpose | Storage for {city} resource group |

## Deployment Location

- **Region**: Australia East (`newzealandnorth`)
- **Reason**: Closest Azure region to New Zealand for optimal latency

## Estimated Cost

Based on Standard_LRS storage in Australia East region:
- **Storage Account**: ~$0.02/GB per month
- **10 Storage Accounts (minimal data)**: ~$5-10/month total
- **Resource Groups**: Free (no charge for resource groups themselves)

*Note: Actual costs depend on data stored, transactions, and data transfer.*

## Compliance & Best Practices

This deployment follows:
- ✅ Azure Cloud Adoption Framework naming conventions
- ✅ Azure Well-Architected Framework security guidelines
- ✅ Infrastructure as Code best practices (Bicep)
- ✅ Least privilege security model
- ✅ Encryption by default
- ✅ Resource tagging for governance

## Validation

All templates have been validated using:
- ✅ Bicep compilation (no errors)
- ✅ Naming convention checks (all pass)
- ✅ Storage account name length validation (all within 24 chars)
- ✅ Security best practice validation (all pass)
- ✅ API version checks (using latest stable versions)

## Next Steps

1. **Review**: Review the Bicep templates in `infra/`
2. **Preview**: Run `az deployment sub what-if` to preview changes
3. **Deploy**: Execute `./infra/deploy.sh` to create resources
4. **Verify**: Check Azure Portal for created resources
5. **Configure**: Add additional settings as needed (networking, access policies, etc.)
