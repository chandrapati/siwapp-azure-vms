# create_nsg.tf
# Network Security Group configuration

resource "azurerm_network_security_group" "nsg" {
  name                = "siwapp-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow all inbound from 0.0.0.0/1
  security_rule {
    name                       = "AllowAll-Inbound"
    priority                   = var.nsg_priority_base
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.nsg_all_cidr_block
    destination_address_prefix = "*"
  }

  # Allow all outbound
  security_rule {
    name                       = "AllowAll-Outbound"
    priority                   = var.nsg_priority_base
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Owner           = var.owner
    ApplicationName = "siwapp"
    Scope           = "prod"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
