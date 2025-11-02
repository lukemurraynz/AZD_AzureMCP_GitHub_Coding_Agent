// Storage Account module for creating storage accounts in each resource group
// Following Azure best practice naming conventions and security guidelines

@description('Name of the storage account (must be 3-24 characters, lowercase letters and numbers only)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The Azure region where the storage account will be deployed')
param location string

@description('City name for tagging purposes')
param city string

@description('Environment name for tagging purposes')
param environment string

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param sku string = 'Standard_LRS'

@description('Storage account kind')
@allowed([
  'StorageV2'
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
])
param kind string = 'StorageV2'

// Create Storage Account following Azure best practices
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    // Security best practices
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true // Can be set to false if using only Azure AD authentication
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: 'Allow' // Consider setting to 'Deny' and adding specific rules for production
      bypass: 'AzureServices'
    }
  }
  tags: {
    Environment: environment
    City: city
    Country: 'NewZealand'
    ManagedBy: 'Bicep'
    Purpose: 'Storage for ${city} resource group'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
