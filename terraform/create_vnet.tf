# create_vnet.tf
# Virtual Network configuration

resource "azurerm_virtual_network" "vnet" {
  name                = "siwapp-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr_block]

  tags = {
    Owner           = var.owner
    ApplicationName = "siwapp"
    Scope           = "prod"
  }
}
