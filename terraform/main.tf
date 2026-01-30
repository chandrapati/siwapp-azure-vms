# main.tf
# Main configuration file for Azure Siwapp deployment

# Generate random string for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.azure_region

  tags = {
    Owner           = var.owner
    ApplicationName = "siwapp"
    Scope           = "prod"
    ManagedBy       = "Terraform"
  }
}

# Storage Account for boot diagnostics
resource "azurerm_storage_account" "diag" {
  name                     = "siwappdiag${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  
  # Cisco Azure Policy Compliance
  allow_nested_items_to_be_public = false
  
  tags = {
    Owner           = var.owner
    ApplicationName = "siwapp"
  }
}