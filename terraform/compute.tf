# compute.tf
# Virtual Machine configurations for Siwapp deployment
# 8 VMs total: 1 DB LB, 3 DB servers, 1 App LB, 3 App servers

# ==============================================================================
# DATABASE LOAD BALANCER
# ==============================================================================

resource "azurerm_public_ip" "dblb_pip" {
  name                = "siwapp-dblb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_db_lb"
    ApplicationName = "siwapp"
    Scope           = "prod"
    ansible_group   = "vm_tag_db_lb"
  }
}

resource "azurerm_network_interface" "dblb_nic" {
  name                = "siwapp-dblb-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dblb_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_db_lb"
    ansible_group = "vm_tag_db_lb"
  }
}

resource "azurerm_linux_virtual_machine" "dblb" {
  name                = "siwapp-dblb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.dblb_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_db_lb"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_db_lb"
    ApplicationName     = "siwapp"
    Scope               = "prod"
  }
}

# ==============================================================================
# DATABASE SERVER 1 (Lead)
# ==============================================================================

resource "azurerm_public_ip" "db1_pip" {
  name                = "siwapp-db1-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_db1"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_db"
  }
}

resource "azurerm_network_interface" "db1_nic" {
  name                = "siwapp-db1-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db1_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_db1"
    ansible_group = "vm_tag_db"
  }
}

resource "azurerm_linux_virtual_machine" "db1" {
  name                = "siwapp-db1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.db1_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_db1"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_db"
    ApplicationName     = "siwapp"
    Scope               = "prod"
    Lead                = "true"
  }
}

# ==============================================================================
# DATABASE SERVER 2
# ==============================================================================

resource "azurerm_public_ip" "db2_pip" {
  name                = "siwapp-db2-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_db2"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_db"
  }
}

resource "azurerm_network_interface" "db2_nic" {
  name                = "siwapp-db2-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db2_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_db2"
    ansible_group = "vm_tag_db"
  }
}

resource "azurerm_linux_virtual_machine" "db2" {
  name                = "siwapp-db2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.db2_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_db2"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_db"
    ApplicationName     = "siwapp"
    Scope               = "prod"
    Lead                = "false"
  }
}

# ==============================================================================
# DATABASE SERVER 3
# ==============================================================================

resource "azurerm_public_ip" "db3_pip" {
  name                = "siwapp-db3-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_db3"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_db"
  }
}

resource "azurerm_network_interface" "db3_nic" {
  name                = "siwapp-db3-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db3_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_db3"
    ansible_group = "vm_tag_db"
  }
}

resource "azurerm_linux_virtual_machine" "db3" {
  name                = "siwapp-db3"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.db3_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_db3"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_db"
    ApplicationName     = "siwapp"
    Scope               = "prod"
    Lead                = "false"
  }
}

# ==============================================================================
# APPLICATION LOAD BALANCER
# ==============================================================================

resource "azurerm_public_ip" "applb_pip" {
  name                = "siwapp-applb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_app_lb"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_app_lb"
  }
}

resource "azurerm_network_interface" "applb_nic" {
  name                = "siwapp-applb-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.applb_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_app_lb"
    ansible_group = "vm_tag_app_lb"
  }
}

resource "azurerm_linux_virtual_machine" "applb" {
  name                = "siwapp-applb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.applb_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_app_lb"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_app_lb"
    ApplicationName     = "siwapp"
    Scope               = "prod"
  }
}

# ==============================================================================
# APPLICATION SERVER 1
# ==============================================================================

resource "azurerm_public_ip" "app1_pip" {
  name                = "siwapp-app1-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_app1"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_app"
  }
}

resource "azurerm_network_interface" "app1_nic" {
  name                = "siwapp-app1-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app1_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_app1"
    ansible_group = "vm_tag_app"
  }
}

resource "azurerm_linux_virtual_machine" "app1" {
  name                = "siwapp-app1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.app1_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_app1"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_app"
    ApplicationName     = "siwapp"
    Scope               = "prod"
  }
}

# ==============================================================================
# APPLICATION SERVER 2
# ==============================================================================

resource "azurerm_public_ip" "app2_pip" {
  name                = "siwapp-app2-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_app2"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_app"
  }
}

resource "azurerm_network_interface" "app2_nic" {
  name                = "siwapp-app2-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app2_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_app2"
    ansible_group = "vm_tag_app"
  }
}

resource "azurerm_linux_virtual_machine" "app2" {
  name                = "siwapp-app2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.app2_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_app2"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_app"
    ApplicationName     = "siwapp"
    Scope               = "prod"
  }
}

# ==============================================================================
# APPLICATION SERVER 3
# ==============================================================================

resource "azurerm_public_ip" "app3_pip" {
  name                = "siwapp-app3-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Owner           = var.owner
    Name            = "siwapp_app3"
    ApplicationName = "siwapp"
    ansible_group   = "vm_tag_app"
  }
}

resource "azurerm_network_interface" "app3_nic" {
  name                = "siwapp-app3-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app3_pip.id
  }

  tags = {
    Owner         = var.owner
    Name          = "siwapp_app3"
    ansible_group = "vm_tag_app"
  }
}

resource "azurerm_linux_virtual_machine" "app3" {
  name                = "siwapp-app3"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.app3_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  boot_diagnostics {
    storage_account_uri = var.enable_boot_diagnostics ? azurerm_storage_account.diag.primary_blob_endpoint : null
  }

  tags = {
    Owner               = var.owner
    Name                = "siwapp_app3"
    KeepInstanceRunning = "false"
    ansible_group       = "vm_tag_app"
    ApplicationName     = "siwapp"
    Scope               = "prod"
  }
}
