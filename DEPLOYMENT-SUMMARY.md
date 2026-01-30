# Siwapp Azure Deployment - Summary

Quick deployment summary matching AWS framework.

---

## What Gets Deployed

### Virtual Machines (8 total)
1. **siwapp-dblb** - Database Load Balancer
2. **siwapp-db1** - Database Server 1 (Lead)
3. **siwapp-db2** - Database Server 2
4. **siwapp-db3** - Database Server 3
5. **siwapp-applb** - Application Load Balancer
6. **siwapp-app1** - Application Server 1
7. **siwapp-app2** - Application Server 2
8. **siwapp-app3** - Application Server 3

### Network Infrastructure
- 1x Virtual Network (10.255.0.0/16)
- 1x Subnet (10.255.1.0/24)
- 1x Network Security Group
- 8x Public IP Addresses
- 8x Network Interfaces

### Storage
- 1x Storage Account (diagnostics)
- 8x 50GB Premium SSD disks

---

## Architecture Pattern

```
DATABASE TIER:
  DB LB → DB1 (Lead), DB2, DB3

APPLICATION TIER:
  App LB → App1, App2, App3
```

All VMs have:
- Public IP addresses
- SSH access
- Ubuntu 22.04 LTS
- 2 vCPU, 4GB RAM (Standard_B2s)
- 50GB Premium SSD

---

## Security

### Network Security Group
- Inbound: 0.0.0.0/1 → ALL
- Outbound: ALL

**⚠️ Update NSG CIDR to your IP range!**

### Access
- SSH only (password auth disabled)
- Key-based authentication
- Admin user: azureuser

---

## Cost Estimate

Monthly cost (24/7 operation):
- 8x VMs: ~$240
- 8x Public IPs: ~$24
- 400GB Storage: ~$60
- **Total: ~$324/month**

**Cost Savings:**
- Stop VMs when not in use
- Use Standard_B1s for dev (~$130/month total)
- Remove public IPs from non-LB VMs

---

## Deployment Time

- Infrastructure: 10-15 minutes
- Total: ~15 minutes

---

## After Deployment

1. Get public IPs: `terraform output`
2. SSH to VMs: `terraform output ssh_commands`
3. Configure with Ansible
4. Update NSG rules
5. Set up monitoring

---

## Quick Commands

```bash
# Deploy
./deploy.sh

# View outputs
cd terraform && terraform output

# SSH to App LB
ssh -i siwapp-key azureuser@<PUBLIC_IP>

# Stop all VMs
for vm in dblb db1 db2 db3 applb app1 app2 app3; do
  az vm deallocate --resource-group siwapp-rg --name siwapp-$vm --no-wait
done

# Cleanup
./cleanup.sh
```

---

## Ansible Groups

- **vm_tag_db_lb**: siwapp-dblb
- **vm_tag_db**: siwapp-db1, siwapp-db2, siwapp-db3
- **vm_tag_app_lb**: siwapp-applb
- **vm_tag_app**: siwapp-app1, siwapp-app2, siwapp-app3

---

**See README.md for complete documentation**
