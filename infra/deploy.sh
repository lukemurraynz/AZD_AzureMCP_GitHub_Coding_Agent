#!/bin/bash

# Deployment script for New Zealand Resource Groups and Storage Accounts
# This script uses Azure CLI to deploy the Bicep infrastructure

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}NZ Resource Groups Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI found${NC}"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Please login...${NC}"
    az login
fi

echo -e "${GREEN}✓ Logged in to Azure${NC}"

# Get current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${GREEN}Current subscription: ${SUBSCRIPTION}${NC}"

# Set default values
LOCATION="${LOCATION:-newzealandnorth}"
ENVIRONMENT="${ENVIRONMENT:-prod}"
DEPLOYMENT_NAME="nz-resources-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S)"

echo ""
echo -e "${YELLOW}Deployment Parameters:${NC}"
echo "  Location: ${LOCATION}"
echo "  Environment: ${ENVIRONMENT}"
echo "  Deployment Name: ${DEPLOYMENT_NAME}"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# Run what-if analysis
echo ""
echo -e "${YELLOW}Running what-if analysis...${NC}"
az deployment sub what-if \
    --name "${DEPLOYMENT_NAME}-whatif" \
    --location "${LOCATION}" \
    --template-file infra/nz-resource-groups.bicep \
    --parameters location="${LOCATION}" environment="${ENVIRONMENT}"

echo ""
read -p "Do you want to continue with the actual deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled after what-if analysis.${NC}"
    exit 0
fi

# Deploy the infrastructure
echo ""
echo -e "${GREEN}Starting deployment...${NC}"
az deployment sub create \
    --name "${DEPLOYMENT_NAME}" \
    --location "${LOCATION}" \
    --template-file infra/nz-resource-groups.bicep \
    --parameters location="${LOCATION}" environment="${ENVIRONMENT}"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Get outputs
    echo ""
    echo -e "${YELLOW}Resource Groups created:${NC}"
    az deployment sub show --name "${DEPLOYMENT_NAME}" \
        --query 'properties.outputs.resourceGroupNames.value[]' -o tsv
    
    echo ""
    echo -e "${YELLOW}Storage Accounts created:${NC}"
    az deployment sub show --name "${DEPLOYMENT_NAME}" \
        --query 'properties.outputs.storageAccountNames.value[]' -o tsv
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Deployment failed!${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
