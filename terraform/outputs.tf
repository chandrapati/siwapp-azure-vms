# outputs.tf
# Output values for the Siwapp deployment

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "azure_region" {
  description = "Azure region"
  value       = azurerm_resource_group.main.location
}

# Network Information
output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = azurerm_subnet.subnet.id
}

output "nsg_id" {
  description = "Network Security Group ID"
  value       = azurerm_network_security_group.nsg.id
}

# Database Load Balancer
output "dblb_public_ip" {
  description = "Database Load Balancer Public IP"
  value       = azurerm_public_ip.dblb_pip.ip_address
}

output "dblb_private_ip" {
  description = "Database Load Balancer Private IP"
  value       = azurerm_network_interface.dblb_nic.private_ip_address
}

# Database Servers
output "db1_public_ip" {
  description = "Database Server 1 Public IP"
  value       = azurerm_public_ip.db1_pip.ip_address
}

output "db1_private_ip" {
  description = "Database Server 1 Private IP"
  value       = azurerm_network_interface.db1_nic.private_ip_address
}

output "db2_public_ip" {
  description = "Database Server 2 Public IP"
  value       = azurerm_public_ip.db2_pip.ip_address
}

output "db2_private_ip" {
  description = "Database Server 2 Private IP"
  value       = azurerm_network_interface.db2_nic.private_ip_address
}

output "db3_public_ip" {
  description = "Database Server 3 Public IP"
  value       = azurerm_public_ip.db3_pip.ip_address
}

output "db3_private_ip" {
  description = "Database Server 3 Private IP"
  value       = azurerm_network_interface.db3_nic.private_ip_address
}

# Application Load Balancer
output "applb_public_ip" {
  description = "Application Load Balancer Public IP"
  value       = azurerm_public_ip.applb_pip.ip_address
}

output "applb_private_ip" {
  description = "Application Load Balancer Private IP"
  value       = azurerm_network_interface.applb_nic.private_ip_address
}

# Application Servers
output "app1_public_ip" {
  description = "Application Server 1 Public IP"
  value       = azurerm_public_ip.app1_pip.ip_address
}

output "app1_private_ip" {
  description = "Application Server 1 Private IP"
  value       = azurerm_network_interface.app1_nic.private_ip_address
}

output "app2_public_ip" {
  description = "Application Server 2 Public IP"
  value       = azurerm_public_ip.app2_pip.ip_address
}

output "app2_private_ip" {
  description = "Application Server 2 Private IP"
  value       = azurerm_network_interface.app2_nic.private_ip_address
}

output "app3_public_ip" {
  description = "Application Server 3 Public IP"
  value       = azurerm_public_ip.app3_pip.ip_address
}

output "app3_private_ip" {
  description = "Application Server 3 Private IP"
  value       = azurerm_network_interface.app3_nic.private_ip_address
}

# SSH Connection Commands
output "ssh_commands" {
  description = "SSH commands to connect to VMs"
  value = <<-EOT
    # Database Load Balancer
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.dblb_pip.ip_address}
    
    # Database Server 1 (Lead)
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.db1_pip.ip_address}
    
    # Database Server 2
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.db2_pip.ip_address}
    
    # Database Server 3
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.db3_pip.ip_address}
    
    # Application Load Balancer
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.applb_pip.ip_address}
    
    # Application Server 1
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.app1_pip.ip_address}
    
    # Application Server 2
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.app2_pip.ip_address}
    
    # Application Server 3
    ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.app3_pip.ip_address}
  EOT
}

# Deployment Summary
output "deployment_summary" {
  description = "Deployment summary information"
  value = <<-EOT
    ╔════════════════════════════════════════════════════════════╗
    ║       SIWAPP DEPLOYMENT SUCCESSFUL - AZURE VMs             ║
    ╚════════════════════════════════════════════════════════════╝
    
    📊 Infrastructure Details:
       • Resource Group: ${azurerm_resource_group.main.name}
       • Region: ${azurerm_resource_group.main.location}
       • VNet CIDR: ${var.vnet_cidr_block}
       • Subnet CIDR: ${var.subnet_cidr_block}
       • VM Size: ${var.vm_size}
       • OS Disk: ${var.os_disk_size_gb}GB ${var.os_disk_type}
    
    🖥️  Virtual Machines Deployed (8 total):
    
    DATABASE TIER:
       • DB Load Balancer: ${azurerm_public_ip.dblb_pip.ip_address}
       • DB Server 1 (Lead): ${azurerm_public_ip.db1_pip.ip_address}
       • DB Server 2: ${azurerm_public_ip.db2_pip.ip_address}
       • DB Server 3: ${azurerm_public_ip.db3_pip.ip_address}
    
    APPLICATION TIER:
       • App Load Balancer: ${azurerm_public_ip.applb_pip.ip_address}
       • App Server 1: ${azurerm_public_ip.app1_pip.ip_address}
       • App Server 2: ${azurerm_public_ip.app2_pip.ip_address}
       • App Server 3: ${azurerm_public_ip.app3_pip.ip_address}
    
    🔐 Security:
       • NSG CIDR Block: ${var.nsg_all_cidr_block}
       • SSH Key: ${var.ssh_public_key_path}
       • Admin User: ${var.admin_username}
    
    📝 Next Steps:
       1. SSH into VMs using commands above
       2. Run Ansible playbooks for application setup
       3. Configure database cluster
       4. Configure application load balancer
       5. Update NSG rules to restrict access further
    
    💰 Estimated Monthly Cost: ~$240 (8x Standard_B2s VMs 24/7)
    
    ⚠️  IMPORTANT: Update nsg_all_cidr_block from 0.0.0.0/1 to your IP range!
    
    📚 View all outputs: terraform output
  EOT
}
