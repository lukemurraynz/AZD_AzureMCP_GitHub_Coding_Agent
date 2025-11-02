// Bicep template for creating Resource Groups in Azure based on New Zealand main cities
// Following Azure best practice naming conventions

targetScope = 'subscription'

@description('The Azure region where resources will be deployed')
param location string = 'australiaeast'

@description('Environment name (e.g., prod, dev, test)')
param environment string = 'prod'

@description('List of New Zealand main cities for resource group naming')
var nzCities = [
  'auckland'
  'wellington'
  'christchurch'
  'hamilton'
  'tauranga'
  'napier'
  'dunedin'
  'palmerstonnorth'
  'nelson'
  'rotorua'
]

@description('Abbreviated city names for storage account naming (must keep total length under 24 chars)')
var nzCityAbbreviations = [
  'akl'        // auckland
  'wlg'        // wellington
  'chc'        // christchurch
  'hlt'        // hamilton
  'trg'        // tauranga
  'npr'        // napier
  'dud'        // dunedin
  'pmr'        // palmerstonnorth
  'nsn'        // nelson
  'rot'        // rotorua
]

// Create Resource Groups for each NZ city following naming convention: rg-<city>-<environment>-<region>-001
resource resourceGroups 'Microsoft.Resources/resourceGroups@2024-03-01' = [for (city, i) in nzCities: {
  name: 'rg-${city}-${environment}-${location}-001'
  location: location
  tags: {
    Environment: environment
    City: city
    Country: 'NewZealand'
    ManagedBy: 'Bicep'
    Purpose: 'NZ City Resource Group'
  }
}]

// Create Storage Accounts in each Resource Group following naming convention: st<cityabbrev><environment>001
// Note: Storage account names must be 3-24 characters, lowercase letters and numbers only
// Using abbreviated city names to stay within the 24-character limit
module storageAccounts 'storage-account.bicep' = [for (city, i) in nzCities: {
  name: 'deploy-storage-${city}'
  scope: resourceGroups[i]
  params: {
    storageAccountName: 'st${nzCityAbbreviations[i]}${environment}001'
    location: location
    city: city
    environment: environment
  }
}]

output resourceGroupNames array = [for (city, i) in nzCities: resourceGroups[i].name]
output storageAccountNames array = [for (city, i) in nzCities: 'st${nzCityAbbreviations[i]}${environment}001']
