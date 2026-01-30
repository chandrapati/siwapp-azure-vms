#!/bin/bash
#
# SIWAPP Azure Deployment - Quick Start Script
# This script helps you deploy SIWAPP infrastructure to Azure
#

set -e  # Exit on any error

echo "=========================================="
echo "  SIWAPP Azure Deployment - Quick Start"
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

# Check prerequisites
print_header "Step 1: Checking prerequisites"

# Check if terraform is installed
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version | head -n 1)
    print_success "Terraform installed: $TERRAFORM_VERSION"
else
    print_error "Terraform is not installed"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

# Check if Azure CLI is installed
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query \"azure-cli\" -o tsv)
    print_success "Azure CLI installed: $AZ_VERSION"
else
    print_error "Azure CLI is not installed"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Verify Azure credentials
print_header "Step 2: Verifying Azure credentials"

if az account show &> /dev/null; then
    AZURE_SUBSCRIPTION=$(az account show --query name -o tsv)
    AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    AZURE_USER=$(az account show --query user.name -o tsv)
    print_success "Azure credentials configured"
    print_info "Subscription: $AZURE_SUBSCRIPTION"
    print_info "Subscription ID: $AZURE_SUBSCRIPTION_ID"
    print_info "User: $AZURE_USER"
else
    print_error "Azure credentials not configured"
    echo "Please run: az login"
    exit 1
fi

# Check for SSH key pair
print_header "Step 3: Checking SSH key pair"

if [ -f "./siwapp-key" ] && [ -f "./siwapp-key.pub" ]; then
    print_success "SSH key pair found (siwapp-key, siwapp-key.pub)"
else
    print_warning "SSH key pair not found"
    echo ""
    read -p "Would you like to create it now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ssh-keygen -t rsa -b 4096 -f ./siwapp-key -C "siwapp@azure" -N ""
        chmod 600 siwapp-key
        chmod 644 siwapp-key.pub
        print_success "SSH key pair created (siwapp-key, siwapp-key.pub)"
    else
        print_error "Cannot proceed without SSH key pair"
        exit 1
    fi
fi

# Navigate to terraform directory
print_header "Step 4: Preparing Terraform configuration"

cd terraform

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found"
    print_info "Creating default terraform.tfvars..."
    
    cat > terraform.tfvars << 'TFVARS'
# Azure Siwapp Deployment Configuration

# General Settings
azure_region        = "East US"
resource_group_name = "siwapp-rg"
owner               = "sujichan"

# Network Configuration
vnet_cidr_block    = "10.255.0.0/16"
subnet_cidr_block  = "10.255.1.0/24"
nsg_all_cidr_block = "0.0.0.0/1"

# SSH Configuration
ssh_public_key_path  = "../siwapp-key.pub"
ssh_private_key_path = "../siwapp-key"
admin_username       = "azureuser"

# VM Configuration
vm_size         = "Standard_B2s"
os_disk_size_gb = 50
os_disk_type    = "Premium_LRS"

# Enable boot diagnostics
enable_boot_diagnostics = true
TFVARS
    
    print_success "Created terraform.tfvars with default values"
    print_warning "IMPORTANT: Review and update terraform.tfvars before deployment!"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to exit and edit configuration..."
fi

# Show configuration summary
print_header "Step 5: Configuration Summary"

if [ -f "terraform.tfvars" ]; then
    echo "Current configuration:"
    echo ""
    grep -E "^[a-z_]+ *=" terraform.tfvars | while read line; do
        print_info "$line"
    done
    echo ""
fi

# Security warning
print_header "⚠️  SECURITY WARNING ⚠️"
echo "The default NSG CIDR block is 0.0.0.0/1 (very broad!)"
echo "This allows access from half the internet."
echo ""
NSG_CIDR=$(grep nsg_all_cidr_block terraform.tfvars | cut -d'"' -f2)
if [[ "$NSG_CIDR" == "0.0.0.0/1" ]] || [[ "$NSG_CIDR" == "0.0.0.0/0" ]]; then
    print_warning "Current NSG CIDR: $NSG_CIDR (NOT SECURE FOR PRODUCTION!)"
    echo ""
    read -p "Continue anyway? (yes/no): " CONTINUE
    if [[ ! "$CONTINUE" == "yes" ]]; then
        print_error "Deployment cancelled"
        echo "Please update nsg_all_cidr_block in terraform.tfvars to your IP range"
        exit 1
    fi
fi

# Cost estimate
print_header "💰 Cost Estimate"
echo "Estimated monthly cost for this deployment:"
echo ""
echo "  • 8x Standard_B2s VMs (24/7):       ~\$240/month"
echo "  • 8x Public IP addresses:           ~\$24/month"
echo "  • 400GB Premium SSD storage:        ~\$60/month"
echo "  • Network egress (~5GB):            ~\$0.25/month"
echo "  ─────────────────────────────────────────────"
echo "  TOTAL:                              ~\$324/month"
echo ""
print_warning "Stop VMs when not in use to save costs!"
echo ""
read -p "Proceed with deployment? (yes/no): " DEPLOY
if [[ ! "$DEPLOY" == "yes" ]]; then
    print_error "Deployment cancelled"
    exit 0
fi

# Initialize Terraform
print_header "Step 6: Initializing Terraform"

terraform init
print_success "Terraform initialized"

# Validate configuration
print_header "Step 7: Validating Terraform configuration"

terraform validate
print_success "Configuration is valid"

# Plan deployment
print_header "Step 8: Creating deployment plan"

terraform plan -out=tfplan
print_success "Deployment plan created"

echo ""
print_warning "Review the plan above carefully!"
echo ""
read -p "Execute the deployment plan? (yes/no): " EXECUTE
if [[ ! "$EXECUTE" == "yes" ]]; then
    print_error "Deployment cancelled"
    rm -f tfplan
    exit 0
fi

# Apply configuration
print_header "Step 9: Deploying infrastructure"

echo "This will take approximately 10-15 minutes..."
echo ""

START_TIME=$(date +%s)

terraform apply tfplan

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

rm -f tfplan

# Success message
print_header "✓ DEPLOYMENT SUCCESSFUL!"

echo ""
print_success "Infrastructure deployed in ${MINUTES}m ${SECONDS}s"
echo ""

# Display outputs
print_header "📊 Deployment Summary"

terraform output deployment_summary

# Next steps
print_header "📝 Next Steps"

echo "1. SSH into your VMs:"
echo "   terraform output ssh_commands"
echo ""
echo "2. View all public IPs:"
echo "   terraform output | grep public_ip"
echo ""
echo "3. Configure application with Ansible"
echo ""
echo "4. Update NSG rules to restrict access:"
echo "   Edit nsg_all_cidr_block in terraform.tfvars"
echo "   Then run: terraform apply"
echo ""
echo "5. Stop VMs when not in use to save costs:"
echo "   az vm deallocate --resource-group siwapp-rg --name <vm-name>"
echo ""

print_header "🎉 Deployment Complete!"

echo "Your Siwapp infrastructure is ready!"
echo ""
print_info "View all outputs: terraform output"
print_info "Documentation: ../README.md"
print_info "Cleanup: ../cleanup.sh"
echo ""
print_success "Happy deploying! 🚀"

cd ..
