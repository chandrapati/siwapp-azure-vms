# create_subnet.tf
# Subnet configuration

resource "azurerm_subnet" "subnet" {
  name                 = "siwapp-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_block]
}
