# Changelog - Siwapp Azure Deployment

All notable changes to this deployment package.

---

## [1.0.0] - 2026-01-30

### Added
- Initial release of Azure VM deployment
- 8 Virtual Machines (1 DB LB, 3 DB, 1 App LB, 3 App)
- Virtual Network with single subnet
- Network Security Group with CIDR 0.0.0.0/1
- Ubuntu 22.04 LTS image
- Standard_B2s VM size (2 vCPU, 4GB RAM)
- Premium SSD storage (50GB per VM)
- SSH key-based authentication
- Boot diagnostics enabled
- Ansible tags for automation
- Comprehensive documentation
- Automated deploy.sh script
- Automated cleanup.sh script

### Security
- NSG CIDR set to 0.0.0.0/1 (first half of IPv4 space)
- SSH key authentication only (no passwords)
- Public IP addresses on all VMs for direct access
- Configurable admin username
- Boot diagnostics for troubleshooting

### Documentation
- README.md - Complete deployment guide
- QUICKREF.md - Quick reference for common tasks
- CONFIGURATION.md - All configuration options
- DEPLOYMENT-SUMMARY.md - Deployment overview
- CHECKLIST.md - Pre/post deployment checklist
- CHANGELOG.md - This file

### Infrastructure as Code
- Terraform 1.3+ compatible
- Azure Provider ~3.0
- Modular file structure:
  - versions.tf - Provider configuration
  - variables.tf - Variable definitions
  - main.tf - Resource group and storage
  - create_vnet.tf - Virtual network
  - create_subnet.tf - Subnet configuration
  - create_nsg.tf - Security group rules
  - compute.tf - All 8 virtual machines
  - outputs.tf - Deployment outputs

### Cost Optimization
- Configurable VM sizes
- Configurable disk types
- Optional boot diagnostics
- Stop/start capability
- Resource tagging for cost tracking

---

## Security Notice

**IMPORTANT:** The default NSG CIDR block `0.0.0.0/1` allows access from half the internet.

**Before deploying to production:**

1. Update nsg_all_cidr_block in terraform.tfvars
2. Use your specific IP or network range
3. Example: `nsg_all_cidr_block = "203.0.113.0/24"`

Find your IP: `curl ifconfig.me`

---

## Cost Estimates

### Default Configuration (8x Standard_B2s)
- Monthly cost (24/7): ~$324
- Breakdown:
  - VMs: $240
  - Public IPs: $24
  - Storage: $60

### Development Configuration (8x Standard_B1s)
- Monthly cost (24/7): ~$130
- Savings: ~$194/month (60% reduction)

### Cost Saving Tips
1. Stop VMs when not in use (0 compute charges)
2. Use smaller VM sizes for dev/test
3. Use Standard_LRS instead of Premium_LRS
4. Remove public IPs from non-LB VMs

---

## Migration from AWS

This deployment mirrors the AWS EC2 Siwapp deployment:

### Same Architecture
- 8 VMs total
- Database tier: 1 LB + 3 servers
- Application tier: 1 LB + 3 servers
- Lead database server designation
- Ansible group tags

### Azure Equivalents
| AWS | Azure |
|-----|-------|
| EC2 | Virtual Machines |
| VPC | Virtual Network |
| Security Group | Network Security Group |
| Key Pair | SSH Public Key |
| EBS | Managed Disks |
| AMI | VM Image |

### Differences
- No separate route table needed (Azure handles automatically)
- No internet gateway needed (Azure handles automatically)
- Public IPs are separate resources
- Network interfaces are explicit resources
- Boot diagnostics use storage account

---

## Known Issues

None at this time.

---

## Future Enhancements

Planned for future releases:
- [ ] Azure Load Balancer integration
- [ ] Availability Sets for HA
- [ ] Azure Bastion for secure access
- [ ] Private endpoints for storage
- [ ] Azure Monitor integration
- [ ] Log Analytics workspace
- [ ] Backup vault configuration
- [ ] Auto-shutdown schedules
- [ ] Azure Policy compliance
- [ ] Multiple region support

---

## Support

For issues or questions:
1. Check README.md
2. Check QUICKREF.md
3. Check TROUBLESHOOTING section in README.md
4. Review Terraform logs
5. Check Azure Portal diagnostics

---

## License

This deployment code is provided as-is for internal use.  
Siwapp application is licensed under its own terms.

---

**Version**: 1.0.0  
**Release Date**: 2026-01-30  
**Framework**: Based on AWS EC2 deployment v1.2  
**Status**: Production Ready
