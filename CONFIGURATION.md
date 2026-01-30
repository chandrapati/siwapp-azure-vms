# Siwapp Azure Deployment - Configuration Guide

Complete reference for all configuration options matching AWS framework.

---

## Configuration Files

- **variables.tf** - Defines all variables (don't edit)
- **terraform.tfvars** - Your custom values (edit this)

---

## General Settings

**azure_region** - Azure region (default: "East US")  
**resource_group_name** - Resource group name (default: "siwapp-rg")  
**owner** - Owner for tagging (default: "sujichan")

---

## Network Settings

**vnet_cidr_block** - VNet CIDR (default: "10.255.0.0/16")  
**subnet_cidr_block** - Subnet CIDR (default: "10.255.1.0/24")  
**nsg_all_cidr_block** - NSG allowed CIDR (default: "0.0.0.0/1")

---

## VM Settings

**vm_size** - VM size (default: "Standard_B2s")  
**os_disk_size_gb** - Disk size (default: 50)  
**os_disk_type** - Disk type (default: "Premium_LRS")

---

## SSH Settings

**ssh_public_key_path** - SSH public key path  
**ssh_private_key_path** - SSH private key path  
**admin_username** - Admin username (default: "azureuser")

---

## Environment Examples

### Development (~$130/month)
```
vm_size = "Standard_B1s"
os_disk_type = "Standard_LRS"
nsg_all_cidr_block = "0.0.0.0/1"
```

### Production (~$324/month)
```
vm_size = "Standard_B2s"
os_disk_type = "Premium_LRS"
nsg_all_cidr_block = "YOUR_IP/24"
```

---

See README.md for complete documentation.
