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
