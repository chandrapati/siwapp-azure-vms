# variables.tf
# Variables for Azure Siwapp Deployment
 
# Variables for general information
######################################
 
variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "East US"
}
 
variable "owner" {
  description = "Configuration owner"
  type        = string
  default     = "sujichan"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "siwapp-rg"
}
 
# Variables for Virtual Network
######################################
 
variable "vnet_cidr_block" {
  description = "CIDR block for the Virtual Network"
  type        = string
  default     = "10.255.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.255.1.0/24"
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher for flow logs"
  type        = bool
  default     = true
}

# Variables for SSH Key
######################################

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "./siwapp-key.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  default     = "./siwapp-key.pem"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}
 
# Variables for Network Security Group
######################################
 
variable "nsg_all_cidr_block" {
  description = "CIDR block for the security group rules"
  type        = string
  default     = "0.0.0.0/1"
}

variable "nsg_priority_base" {
  description = "Base priority for NSG rules"
  type        = number
  default     = 100
}
 
# Variables for Virtual Machines
######################################

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_image_publisher" {
  description = "VM image publisher"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "VM image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  description = "VM image SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  description = "VM image version"
  type        = string
  default     = "latest"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 50
}

variable "os_disk_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics for VMs"
  type        = bool
  default     = true
}

# Variables for Storage Account (for diagnostics)
######################################

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}
