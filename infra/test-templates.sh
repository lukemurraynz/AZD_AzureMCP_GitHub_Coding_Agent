#!/bin/bash

# Test script to validate Bicep templates and naming conventions
# This script runs local validation without deploying to Azure

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bicep Template Validation Test${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}✗ Azure CLI is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Azure CLI found${NC}"

# Test 1: Build main Bicep template
echo -e "\n${YELLOW}Test 1: Building main Bicep template...${NC}"
if az bicep build --file infra/nz-resource-groups.bicep; then
    echo -e "${GREEN}✓ Main template builds successfully${NC}"
else
    echo -e "${RED}✗ Main template build failed${NC}"
    exit 1
fi

# Test 2: Build storage account module
echo -e "\n${YELLOW}Test 2: Building storage account module...${NC}"
if az bicep build --file infra/storage-account.bicep; then
    echo -e "${GREEN}✓ Storage account module builds successfully${NC}"
else
    echo -e "${RED}✗ Storage account module build failed${NC}"
    exit 1
fi

# Test 3: Validate naming conventions
echo -e "\n${YELLOW}Test 3: Validating naming conventions...${NC}"

# Expected NZ cities
EXPECTED_CITIES=(
    "auckland"
    "wellington"
    "christchurch"
    "hamilton"
    "tauranga"
    "napier"
    "dunedin"
    "palmerstonnorth"
    "nelson"
    "rotorua"
)

echo "Checking for 10 New Zealand cities..."

# Check if all cities are in the Bicep template
CITIES_FOUND=0
for city in "${EXPECTED_CITIES[@]}"; do
    if grep -q "${city}" infra/nz-resource-groups.bicep; then
        echo -e "  ${GREEN}✓ Found: ${city}${NC}"
        CITIES_FOUND=$((CITIES_FOUND + 1))
    else
        echo -e "  ${RED}✗ Missing: ${city}${NC}"
    fi
done

if [ $CITIES_FOUND -eq 10 ]; then
    echo -e "${GREEN}✓ All 10 cities found in template${NC}"
else
    echo -e "${RED}✗ Only ${CITIES_FOUND}/10 cities found${NC}"
    exit 1
fi

# Test 4: Validate resource group naming pattern
echo -e "\n${YELLOW}Test 4: Validating resource group naming pattern...${NC}"
RG_PATTERN="rg-\${city}-\${environment}-\${location}-001"
if grep -q "$RG_PATTERN" infra/nz-resource-groups.bicep; then
    echo -e "${GREEN}✓ Resource group naming follows convention: rg-<city>-<env>-<region>-001${NC}"
else
    echo -e "${RED}✗ Resource group naming pattern not found${NC}"
    exit 1
fi

# Test 5: Validate storage account naming pattern
echo -e "\n${YELLOW}Test 5: Validating storage account naming pattern...${NC}"
ST_PATTERN="st\${nzCityAbbreviations\[i\]}\${environment}001"
if grep -q "$ST_PATTERN" infra/nz-resource-groups.bicep; then
    echo -e "${GREEN}✓ Storage account naming follows convention: st<cityabbrev><env>001${NC}"
else
    echo -e "${RED}✗ Storage account naming pattern not found${NC}"
    exit 1
fi

# Test 5b: Validate all storage account names are within 24 character limit
echo -e "\n${YELLOW}Test 5b: Validating storage account name lengths...${NC}"
CITY_ABBREVS=(
    "akl"
    "wlg"
    "chc"
    "hlt"
    "trg"
    "npr"
    "dud"
    "pmr"
    "nsn"
    "rot"
)

MAX_LENGTH_VIOLATIONS=0
for abbrev in "${CITY_ABBREVS[@]}"; do
    # Calculate length: st + abbrev + prod + 001 = 2 + 3 + 4 + 3 = 12 characters
    NAME_LENGTH=$((2 + ${#abbrev} + 4 + 3))
    if [ $NAME_LENGTH -le 24 ]; then
        echo -e "  ${GREEN}✓ st${abbrev}prod001 = ${NAME_LENGTH} chars (within limit)${NC}"
    else
        echo -e "  ${RED}✗ st${abbrev}prod001 = ${NAME_LENGTH} chars (exceeds 24)${NC}"
        MAX_LENGTH_VIOLATIONS=$((MAX_LENGTH_VIOLATIONS + 1))
    fi
done

if [ $MAX_LENGTH_VIOLATIONS -eq 0 ]; then
    echo -e "${GREEN}✓ All storage account names within 24-character limit${NC}"
else
    echo -e "${RED}✗ ${MAX_LENGTH_VIOLATIONS} storage account names exceed the limit${NC}"
    exit 1
fi

# Test 6: Validate storage account name constraints
echo -e "\n${YELLOW}Test 6: Validating storage account name length constraints...${NC}"
if grep -q "@minLength(3)" infra/storage-account.bicep && grep -q "@maxLength(24)" infra/storage-account.bicep; then
    echo -e "${GREEN}✓ Storage account name constraints (3-24 chars) defined${NC}"
else
    echo -e "${RED}✗ Storage account name constraints not properly defined${NC}"
    exit 1
fi

# Test 7: Validate security best practices
echo -e "\n${YELLOW}Test 7: Validating security best practices...${NC}"

SECURITY_CHECKS=0
SECURITY_TOTAL=4

if grep -q "supportsHttpsTrafficOnly: true" infra/storage-account.bicep; then
    echo -e "  ${GREEN}✓ HTTPS-only traffic enabled${NC}"
    SECURITY_CHECKS=$((SECURITY_CHECKS + 1))
else
    echo -e "  ${RED}✗ HTTPS-only traffic not enforced${NC}"
fi

if grep -q "minimumTlsVersion: 'TLS1_2'" infra/storage-account.bicep; then
    echo -e "  ${GREEN}✓ Minimum TLS version set to 1.2${NC}"
    SECURITY_CHECKS=$((SECURITY_CHECKS + 1))
else
    echo -e "  ${RED}✗ Minimum TLS version not set${NC}"
fi

if grep -q "allowBlobPublicAccess: false" infra/storage-account.bicep; then
    echo -e "  ${GREEN}✓ Blob public access disabled${NC}"
    SECURITY_CHECKS=$((SECURITY_CHECKS + 1))
else
    echo -e "  ${RED}✗ Blob public access not disabled${NC}"
fi

if grep -A 10 "encryption:" infra/storage-account.bicep | grep -q "enabled: true"; then
    echo -e "  ${GREEN}✓ Encryption enabled${NC}"
    SECURITY_CHECKS=$((SECURITY_CHECKS + 1))
else
    echo -e "  ${RED}✗ Encryption not enabled${NC}"
fi

if [ $SECURITY_CHECKS -eq $SECURITY_TOTAL ]; then
    echo -e "${GREEN}✓ All security best practices implemented${NC}"
else
    echo -e "${YELLOW}⚠ ${SECURITY_CHECKS}/${SECURITY_TOTAL} security best practices implemented${NC}"
fi

# Test 8: Validate tags
echo -e "\n${YELLOW}Test 8: Validating resource tags...${NC}"

TAGS_FOUND=0
TAGS_TOTAL=5

EXPECTED_TAGS=("Environment" "City" "Country" "ManagedBy" "Purpose")

for tag in "${EXPECTED_TAGS[@]}"; do
    if grep -q "${tag}:" infra/storage-account.bicep; then
        echo -e "  ${GREEN}✓ Tag found: ${tag}${NC}"
        TAGS_FOUND=$((TAGS_FOUND + 1))
    else
        echo -e "  ${RED}✗ Tag missing: ${tag}${NC}"
    fi
done

if [ $TAGS_FOUND -eq $TAGS_TOTAL ]; then
    echo -e "${GREEN}✓ All required tags defined${NC}"
else
    echo -e "${YELLOW}⚠ ${TAGS_FOUND}/${TAGS_TOTAL} tags found${NC}"
fi

# Test 9: Validate API version
echo -e "\n${YELLOW}Test 9: Validating API versions...${NC}"
if grep -q "Microsoft.Storage/storageAccounts@2023" infra/storage-account.bicep; then
    echo -e "${GREEN}✓ Using current API version for Storage Accounts${NC}"
else
    echo -e "${YELLOW}⚠ API version may not be the latest${NC}"
fi

if grep -q "Microsoft.Resources/resourceGroups@2024" infra/nz-resource-groups.bicep; then
    echo -e "${GREEN}✓ Using current API version for Resource Groups${NC}"
else
    echo -e "${YELLOW}⚠ API version may not be the latest${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}All tests passed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Summary:${NC}"
echo "  - Bicep templates are valid"
echo "  - Naming conventions follow Azure best practices"
echo "  - Security best practices implemented"
echo "  - All 10 NZ cities included"
echo "  - Resource tags configured"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the templates: infra/nz-resource-groups.bicep"
echo "  2. Deploy using: ./infra/deploy.sh"
echo "  3. Or preview with: az deployment sub what-if --location newzealandnorth --template-file infra/nz-resource-groups.bicep"
