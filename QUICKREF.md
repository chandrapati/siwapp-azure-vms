# Siwapp Azure Deployment - Quick Reference

**Fast reference guide for common operations**

---

## 🚀 Quick Deploy

```bash
# 1. Clone/download package
cd siwapp-azure-vms/

# 2. Create SSH keys (if needed)
ssh-keygen -t rsa -b 4096 -f ./siwapp-key -C "siwapp@azure" -N ""

# 3. Login to Azure
az login

# 4. Deploy
./deploy.sh
```

**Time:** ~10-15 minutes

---

## 🔧 Common Commands

### Deployment

```bash
# Full deployment
./deploy.sh

# Manual deployment
cd terraform/
terraform init
terraform plan
terraform apply
```

### Check Status

```bash
# View all VMs
az vm list --resource-group siwapp-rg --output table

# View specific VM
az vm show --resource-group siwapp-rg --name siwapp-app1

# Check VM power state
az vm get-instance-view \
  --resource-group siwapp-rg \
  --name siwapp-app1 \
  --query instanceView.statuses[1] \
  --output table
```

### SSH Access

```bash
# Get all public IPs
cd terraform/
terraform output | grep public_ip

# SSH to specific VM
ssh -i ../siwapp-key azureuser@<PUBLIC_IP>

# SSH to all VMs (example)
ssh -i siwapp-key azureuser@$(cd terraform && terraform output -raw dblb_public_ip)
ssh -i siwapp-key azureuser@$(cd terraform && terraform output -raw db1_public_ip)
ssh -i siwapp-key azureuser@$(cd terraform && terraform output -raw applb_public_ip)
```

### Start/Stop VMs

```bash
# Stop single VM (deallocate = no compute charges)
az vm deallocate --resource-group siwapp-rg --name siwapp-app1

# Start single VM
az vm start --resource-group siwapp-rg --name siwapp-app1

# Stop ALL VMs (saves money!)
for vm in dblb db1 db2 db3 applb app1 app2 app3; do
  az vm deallocate --resource-group siwapp-rg --name siwapp-$vm --no-wait
done

# Start ALL VMs
for vm in dblb db1 db2 db3 applb app1 app2 app3; do
  az vm start --resource-group siwapp-rg --name siwapp-$vm --no-wait
done

# Restart VM
az vm restart --resource-group siwapp-rg --name siwapp-app1
```

### Monitoring

```bash
# View boot diagnostics
az vm boot-diagnostics get-boot-log \
  --resource-group siwapp-rg \
  --name siwapp-app1

# List all resources in group
az resource list --resource-group siwapp-rg --output table

# View NSG rules
az network nsg rule list \
  --resource-group siwapp-rg \
  --nsg-name siwapp-nsg \
  --output table

# Check costs
az consumption usage list \
  --start-date 2026-01-01 \
  --end-date 2026-01-31 \
  --output table
```

### Update Configuration

```bash
cd terraform/

# Edit variables
nano terraform.tfvars

# Apply changes
terraform plan
terraform apply
```

---

## 🧹 Cleanup

```bash
# Full cleanup (deletes everything!)
./cleanup.sh

# Manual cleanup
cd terraform/
terraform destroy
```

---

## 🔒 Security

### Update NSG to Your IP

```bash
# Find your IP
curl ifconfig.me

# Edit terraform.tfvars
cd terraform/
nano terraform.tfvars

# Change this line:
nsg_all_cidr_block = "YOUR_IP/32"

# Apply
terraform apply
```

### Restrict SSH to Specific IPs

```bash
# In terraform.tfvars
nsg_all_cidr_block = "203.0.113.0/24"  # Your office network

# Or multiple IPs (requires code change)
# Add additional NSG rules in create_nsg.tf
```

---

## 📊 Cost Management

### Check Current Costs

```bash
# Via Azure CLI
az consumption usage list --output table

# Via Portal
# https://portal.azure.com > Cost Management > Cost Analysis
```

### Reduce Costs

```bash
# 1. Stop VMs when not in use
az vm deallocate --resource-group siwapp-rg --name siwapp-app1

# 2. Use smaller VM size (edit terraform.tfvars)
vm_size = "Standard_B1s"  # ~$8/month vs $30/month

# 3. Use Standard HDD (edit terraform.tfvars)
os_disk_type = "Standard_LRS"  # vs Premium_LRS

# 4. Remove public IPs from non-LB VMs
# Edit compute.tf to remove public_ip_address_id
```

---

## 🐛 Troubleshooting

### Can't SSH to VM

```bash
# 1. Check VM is running
az vm get-instance-view \
  --resource-group siwapp-rg \
  --name siwapp-app1 \
  --query instanceView.statuses[1]

# 2. Verify NSG rules
az network nsg rule list \
  --resource-group siwapp-rg \
  --nsg-name siwapp-nsg

# 3. Check SSH key permissions
chmod 600 siwapp-key

# 4. Test with verbose SSH
ssh -v -i siwapp-key azureuser@<PUBLIC_IP>
```

### Terraform Errors

```bash
# Refresh state
terraform refresh

# Re-initialize
rm -rf .terraform
terraform init

# Fix state issues
terraform state list
terraform state show <resource>

# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/<id>/resourceGroups/siwapp-rg
```

### Azure CLI Issues

```bash
# Re-login
az login

# Clear cache
az cache purge
az cache delete

# Update CLI
az upgrade
```

---

## 📝 Quick Tips

1. **Always stop VMs when not in use** - Saves ~$240/month
2. **Use terraform.tfvars** - Don't edit variables.tf
3. **Keep SSH keys secure** - Never commit to git
4. **Tag resources** - Already done via Terraform
5. **Monitor costs daily** - Set up alerts in Portal
6. **Backup important data** - Before running cleanup.sh

---

## 📁 File Locations

| File | Location | Purpose |
|------|----------|---------|
| SSH private key | `./siwapp-key` | SSH authentication |
| SSH public key | `./siwapp-key.pub` | VM deployment |
| Terraform config | `./terraform/` | Infrastructure code |
| Variables | `./terraform/terraform.tfvars` | Configuration |
| State file | `./terraform/terraform.tfstate` | Current state |

---

## 🆘 Get Help

```bash
# Terraform help
terraform -help

# Azure CLI help
az vm -h
az network -h

# View outputs
cd terraform/
terraform output

# View detailed output
terraform output deployment_summary
terraform output ssh_commands
```

---

## 🔗 Quick Links

- [Azure Portal](https://portal.azure.com)
- [Terraform Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure VM Docs](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Azure CLI Docs](https://docs.microsoft.com/en-us/cli/azure/)

---

**Need more detail? See README.md for complete documentation.**
