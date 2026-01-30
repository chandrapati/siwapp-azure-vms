#!/bin/bash
#
# SIWAPP Azure Cleanup Script
# This script helps you destroy all SIWAPP infrastructure on Azure
#

set -e  # Exit on any error

echo "=========================================="
echo "  SIWAPP Azure Cleanup - Destroy Resources"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Warning message
print_header "⚠️  DESTRUCTIVE OPERATION WARNING ⚠️"

echo "This script will PERMANENTLY DELETE the following Azure resources:"
echo ""
echo "  • Resource Group: siwapp-rg"
echo "  • 8x Virtual Machines"
echo "  • 8x Public IP addresses"
echo "  • 8x Network interfaces"
echo "  • 1x Virtual Network"
echo "  • 1x Subnet"
echo "  • 1x Network Security Group"
echo "  • 1x Storage account"
echo "  • ALL data stored on these resources"
echo ""
print_error "THIS CANNOT BE UNDONE!"
echo ""

# Check if Terraform directory exists
if [ ! -d "terraform" ]; then
    print_error "Terraform directory not found"
    print_info "Run this script from the siwapp-azure-vms directory"
    exit 1
fi

cd terraform

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_warning "No Terraform state file found"
    print_info "Infrastructure may not be deployed, or state file is missing"
    echo ""
    read -p "Try to destroy anyway? (yes/no): " CONTINUE
    if [[ ! "$CONTINUE" == "yes" ]]; then
        print_error "Cleanup cancelled"
        exit 0
    fi
fi

# Double confirmation
print_header "Confirmation Required"

echo "Type 'destroy' to confirm deletion of ALL resources:"
read -p "> " CONFIRM

if [[ ! "$CONFIRM" == "destroy" ]]; then
    print_error "Cleanup cancelled"
    print_info "You typed: $CONFIRM"
    print_info "Expected: destroy"
    exit 0
fi

echo ""
print_warning "Last chance! Are you absolutely sure?"
read -p "Type 'yes' to proceed: " FINAL_CONFIRM

if [[ ! "$FINAL_CONFIRM" == "yes" ]]; then
    print_error "Cleanup cancelled"
    exit 0
fi

# Show what will be destroyed
print_header "Step 1: Reviewing resources to destroy"

terraform plan -destroy

echo ""
read -p "Proceed with destruction? (yes/no): " PROCEED

if [[ ! "$PROCEED" == "yes" ]]; then
    print_error "Cleanup cancelled"
    exit 0
fi

# Destroy infrastructure
print_header "Step 2: Destroying Azure infrastructure"

echo "This may take 5-10 minutes..."
echo ""

START_TIME=$(date +%s)

terraform destroy -auto-approve

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Cleanup local files
print_header "Step 3: Cleaning up local files"

if [ -f "terraform.tfstate" ]; then
    rm -f terraform.tfstate
    print_success "Removed terraform.tfstate"
fi

if [ -f "terraform.tfstate.backup" ]; then
    rm -f terraform.tfstate.backup
    print_success "Removed terraform.tfstate.backup"
fi

if [ -f ".terraform.lock.hcl" ]; then
    rm -f .terraform.lock.hcl
    print_success "Removed .terraform.lock.hcl"
fi

if [ -d ".terraform" ]; then
    rm -rf .terraform
    print_success "Removed .terraform directory"
fi

if [ -f "tfplan" ]; then
    rm -f tfplan
    print_success "Removed tfplan"
fi

# Verify with Azure CLI
print_header "Step 4: Verifying resource deletion"

if command -v az &> /dev/null; then
    if az group show --name siwapp-rg &> /dev/null; then
        print_warning "Resource group still exists (may be deleting)"
        print_info "Check status: az group show --name siwapp-rg"
    else
        print_success "Resource group deleted successfully"
    fi
else
    print_warning "Azure CLI not available for verification"
fi

# Success message
print_header "✓ CLEANUP COMPLETE"

echo ""
print_success "Infrastructure destroyed in ${MINUTES}m ${SECONDS}s"
echo ""
print_info "All Azure resources have been deleted"
print_info "All Terraform state files have been removed"
echo ""

# Optional: Remove SSH keys
print_header "🔑 SSH Keys"

if [ -f "../siwapp-key" ] || [ -f "../siwapp-key.pub" ]; then
    echo "SSH key files still exist:"
    [ -f "../siwapp-key" ] && print_info "siwapp-key (private)"
    [ -f "../siwapp-key.pub" ] && print_info "siwapp-key.pub (public)"
    echo ""
    read -p "Delete SSH keys? (yes/no): " DELETE_KEYS
    
    if [[ "$DELETE_KEYS" == "yes" ]]; then
        [ -f "../siwapp-key" ] && rm ../siwapp-key && print_success "Deleted siwapp-key"
        [ -f "../siwapp-key.pub" ] && rm ../siwapp-key.pub && print_success "Deleted siwapp-key.pub"
    else
        print_info "SSH keys preserved"
    fi
fi

cd ..

print_header "🎉 All Done!"

echo "Your Azure resources have been completely removed."
echo ""
print_success "You will no longer be charged for these resources"
echo ""
print_info "To redeploy: ./deploy.sh"
echo ""
