# Siwapp on Azure VMs - Deployment Package

![Visitors](https://visitor-badge.laobi.icu/badge?page_id=chandrapati.siwapp-azure-vms&left_text=visitors)

**Version:** 1.0  
**Cloud Provider:** Microsoft Azure  
**Infrastructure:** 8 Virtual Machines  
**Last Updated:** 2026-01-30

---

## 📋 Overview

This package deploys Siwapp invoicing application on Azure using 8 Virtual Machines following the same architecture pattern as the AWS EC2 deployment.

### Architecture

```
┌─────────────────────────────────────────────┐
│                 AZURE VNET                  │
│              (10.255.0.0/16)                │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │         SUBNET                      │    │
│  │      (10.255.1.0/24)               │    │
│  │                                     │    │
│  │  DATABASE TIER:                     │    │
│  │  • DB Load Balancer (Public IP)     │    │
│  │  • DB Server 1 (Lead, Public IP)    │    │
│  │  • DB Server 2 (Public IP)          │    │
│  │  • DB Server 3 (Public IP)          │    │
│  │                                     │    │
│  │  APPLICATION TIER:                  │    │
│  │  • App Load Balancer (Public IP)    │    │
│  │  • App Server 1 (Public IP)         │    │
│  │  • App Server 2 (Public IP)         │    │
│  │  • App Server 3 (Public IP)         │    │
│  │                                     │    │
│  └────────────────────────────────────┘    │
│                                             │
│  Network Security Group:                    │
│  • Inbound: 0.0.0.0/1 → ALL PORTS          │
│  • Outbound: ALL                            │
│                                             │
└─────────────────────────────────────────────┘
```

### Virtual Machines (8 Total)

| Name | Role | Size | Public IP | Ansible Group |
|------|------|------|-----------|---------------|
| siwapp-dblb | Database LB | Standard_B2s | Yes | vm_tag_db_lb |
| siwapp-db1 | DB Server (Lead) | Standard_B2s | Yes | vm_tag_db |
| siwapp-db2 | DB Server | Standard_B2s | Yes | vm_tag_db |
| siwapp-db3 | DB Server | Standard_B2s | Yes | vm_tag_db |
| siwapp-applb | Application LB | Standard_B2s | Yes | vm_tag_app_lb |
| siwapp-app1 | App Server | Standard_B2s | Yes | vm_tag_app |
| siwapp-app2 | App Server | Standard_B2s | Yes | vm_tag_app |
| siwapp-app3 | App Server | Standard_B2s | Yes | vm_tag_app |

---

## 🎯 Features

✅ **8 Virtual Machines** - Matching AWS EC2 deployment structure  
✅ **High Availability** - Multiple DB and App servers  
✅ **Load Balancing** - Dedicated LB VMs for DB and App tiers  
✅ **Public IP Addresses** - All VMs accessible via SSH  
✅ **Network Security** - NSG with CIDR 0.0.0.0/1  
✅ **Boot Diagnostics** - Enabled for troubleshooting  
✅ **Ansible Ready** - Tags for automated configuration  
✅ **Ubuntu 22.04 LTS** - Latest long-term support OS  

---

## 📋 Prerequisites

### Required Tools

1. **Terraform** (>= 1.3)
   ```bash
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Azure CLI** (>= 2.50)
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

3. **SSH Key Pair**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ./siwapp-key -C "siwapp@azure"
   # This creates siwapp-key (private) and siwapp-key.pub (public)
   ```

### Azure Requirements

- Active Azure subscription
- Contributor access or equivalent permissions
- Sufficient quota for 8 VMs

---

## 🚀 Quick Start

### Step 1: Login to Azure

```bash
# Login
az login

# Set subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show
```

### Step 2: Prepare SSH Keys

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -f ./siwapp-key -C "siwapp@azure"

# This creates:
# - siwapp-key (private key)
# - siwapp-key.pub (public key)
```

### Step 3: Configure Variables

The default variables are in `terraform/variables.tf`. To customize, create a `terraform.tfvars` file:

```bash
cd terraform/
cat > terraform.tfvars << 'TFVARS'
# Azure Configuration
azure_region        = "East US"
resource_group_name = "siwapp-rg"
owner               = "your-name"

# Network Configuration
vnet_cidr_block   = "10.255.0.0/16"
subnet_cidr_block = "10.255.1.0/24"
nsg_all_cidr_block = "0.0.0.0/1"

# SSH Configuration
ssh_public_key_path  = "../siwapp-key.pub"
ssh_private_key_path = "../siwapp-key"
admin_username       = "azureuser"

# VM Configuration
vm_size         = "Standard_B2s"
os_disk_size_gb = 50
os_disk_type    = "Premium_LRS"
TFVARS
```

### Step 4: Deploy

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Deploy (takes ~10-15 minutes)
terraform apply

# Confirm with: yes
```

### Step 5: Access VMs

After deployment, get the IP addresses:

```bash
# View all outputs
terraform output

# View SSH commands
terraform output ssh_commands

# SSH to any VM (example: App LB)
ssh -i ../siwapp-key azureuser@<PUBLIC_IP>
```

---

## 📊 Cost Estimate

### Monthly Cost (24/7 operation, East US region)

| Resource | Quantity | Unit Cost | Total |
|----------|----------|-----------|-------|
| Standard_B2s VMs | 8 | ~$30/month | ~$240 |
| Public IP Addresses | 8 | ~$3/month | ~$24 |
| Storage (Premium SSD) | 400GB | ~$0.15/GB | ~$60 |
| Network Egress | ~5GB | ~$0.05/GB | ~$0.25 |
| **TOTAL** | | | **~$324/month** |

### Cost Optimization Tips

1. **Stop VMs when not in use**
   ```bash
   az vm deallocate --resource-group siwapp-rg --name siwapp-app1
   ```

2. **Use smaller VM sizes for dev**
   ```hcl
   vm_size = "Standard_B1s"  # ~$8/month
   ```

3. **Use Standard HDD for non-production**
   ```hcl
   os_disk_type = "Standard_LRS"  # Saves ~$40/month
   ```

4. **Remove public IPs from non-LB VMs**
   - Only keep public IPs on LB VMs
   - Access others via LB as bastion

---

## 🔧 Configuration Details

### Default Configuration

| Setting | Value | Changeable In |
|---------|-------|---------------|
| Region | East US | `variables.tf` |
| Resource Group | siwapp-rg | `variables.tf` |
| VNet CIDR | 10.255.0.0/16 | `variables.tf` |
| Subnet CIDR | 10.255.1.0/24 | `variables.tf` |
| NSG CIDR | 0.0.0.0/1 | `variables.tf` |
| VM Size | Standard_B2s | `variables.tf` |
| OS Image | Ubuntu 22.04 LTS | `variables.tf` |
| Disk Size | 50GB | `variables.tf` |
| Disk Type | Premium_LRS | `variables.tf` |

### VM Specifications

**Standard_B2s:**
- vCPUs: 2
- RAM: 4GB
- Disk: 50GB Premium SSD
- Network: Moderate
- Cost: ~$30/month

---

## 🔒 Security

### Network Security Group (NSG)

**Default Rules:**

**Inbound:**
- Source: 0.0.0.0/1 (first half of IPv4 space)
- Destination: Any
- Ports: All
- Protocol: All

**Outbound:**
- Allow all

### ⚠️ IMPORTANT: Update NSG Rules!

The default CIDR `0.0.0.0/1` is very broad. Update to your specific IP:

```hcl
# In terraform.tfvars
nsg_all_cidr_block = "YOUR_OFFICE_IP/24"

# Or specific IP
nsg_all_cidr_block = "203.0.113.5/32"
```

Then re-apply:
```bash
terraform apply
```

### SSH Key Security

- **Never share private keys**
- Store `siwapp-key` (private) securely
- Only distribute `siwapp-key.pub` (public)
- Use different keys for prod/dev

---

## 🛠️ Operations

### Start/Stop VMs

```bash
# Stop a VM (deallocate - no compute charges)
az vm deallocate \
  --resource-group siwapp-rg \
  --name siwapp-app1

# Start a VM
az vm start \
  --resource-group siwapp-rg \
  --name siwapp-app1

# Stop all VMs (cost savings during off-hours)
for vm in dblb db1 db2 db3 applb app1 app2 app3; do
  az vm deallocate --resource-group siwapp-rg --name siwapp-$vm --no-wait
done

# Start all VMs
for vm in dblb db1 db2 db3 applb app1 app2 app3; do
  az vm start --resource-group siwapp-rg --name siwapp-$vm --no-wait
done
```

### View VM Status

```bash
# List all VMs
az vm list \
  --resource-group siwapp-rg \
  --output table

# Get specific VM details
az vm show \
  --resource-group siwapp-rg \
  --name siwapp-app1
```

### Monitor Resources

```bash
# View costs
az consumption usage list \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --output table

# View resource group metrics
az monitor metrics list \
  --resource-group siwapp-rg
```

---

## 🔄 Ansible Integration

All VMs are tagged with `ansible_group` for automated configuration:

| Ansible Group | VMs |
|---------------|-----|
| vm_tag_db_lb | siwapp-dblb |
| vm_tag_db | siwapp-db1, siwapp-db2, siwapp-db3 |
| vm_tag_app_lb | siwapp-applb |
| vm_tag_app | siwapp-app1, siwapp-app2, siwapp-app3 |

### Generate Ansible Inventory

```bash
# Dynamic inventory using Azure tags
az vm list \
  --resource-group siwapp-rg \
  --query "[].{name:name, ip:publicIps[0].ipAddress, group:tags.ansible_group}" \
  --output table
```

---

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform/
terraform destroy

# Confirm with: yes
```

This will delete:
- All 8 Virtual Machines
- All Public IP addresses
- Network interfaces
- Storage account
- Virtual Network
- Subnet
- Network Security Group
- Resource Group

**Note:** Stopped but not deleted resources still incur storage charges.

---

## 📝 File Structure

```
siwapp-azure-vms/
├── README.md                    # This file
├── DEPLOYMENT-SUMMARY.md        # Quick reference
├── deploy.sh                    # Automated deployment script
├── cleanup.sh                   # Cleanup script
├── siwapp-key                   # SSH private key (create this)
├── siwapp-key.pub              # SSH public key (create this)
│
└── terraform/
    ├── versions.tf              # Provider configuration
    ├── variables.tf             # All variables
    ├── main.tf                  # Resource group & storage
    ├── create_vnet.tf          # Virtual network
    ├── create_subnet.tf        # Subnet
    ├── create_nsg.tf           # Security group
    ├── compute.tf              # All 8 VMs
    └── outputs.tf              # Outputs
```

---

## 🐛 Troubleshooting

### Issue: "Terraform command not found"
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Issue: "Azure CLI not installed"
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Issue: "Insufficient quota"
```bash
# Check quota
az vm list-usage --location "East US" --output table

# Request increase via Azure Portal
# Support > New Support Request > Service and subscription limits (quotas)
```

### Issue: "SSH key not found"
```bash
# Generate new key
ssh-keygen -t rsa -b 4096 -f ./siwapp-key -C "siwapp@azure"

# Update path in terraform.tfvars
ssh_public_key_path = "./siwapp-key.pub"
```

### Issue: "Cannot SSH to VMs"
```bash
# 1. Check NSG rules
az network nsg rule list \
  --resource-group siwapp-rg \
  --nsg-name siwapp-nsg \
  --output table

# 2. Verify SSH key permissions
chmod 600 siwapp-key
chmod 644 siwapp-key.pub

# 3. Test connection
ssh -v -i siwapp-key azureuser@<PUBLIC_IP>
```

---

## 📚 Additional Resources

- [Azure Virtual Machines Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)

---

## 🙏 Credits

**Created by:** DevOps Team  
**Based on:** AWS EC2 Siwapp deployment framework  
**Version:** 1.0  
**Last Updated:** 2026-01-30

---

**Ready to deploy? Follow the Quick Start guide above! 🚀**
