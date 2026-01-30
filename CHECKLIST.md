# Siwapp Azure Deployment - Checklist

Use this checklist to ensure successful deployment.

---

## Pre-Deployment Checklist

### Environment Setup
- [ ] Terraform installed (>= 1.3)
- [ ] Azure CLI installed (>= 2.50)
- [ ] Azure account with active subscription
- [ ] Sufficient permissions (Contributor or equivalent)
- [ ] Quota verified (8 VMs available in region)

### Authentication
- [ ] Azure CLI logged in: `az login`
- [ ] Correct subscription selected: `az account show`
- [ ] Subscription ID noted

### SSH Keys
- [ ] SSH key pair generated
- [ ] Private key: `./siwapp-key` (chmod 600)
- [ ] Public key: `./siwapp-key.pub` (chmod 644)
- [ ] Keys NOT committed to version control

### Configuration
- [ ] terraform.tfvars created
- [ ] azure_region set
- [ ] resource_group_name set (unique)
- [ ] owner name set
- [ ] ssh_public_key_path points to correct file
- [ ] ssh_private_key_path points to correct file
- [ ] admin_username set

### Security Review
- [ ] nsg_all_cidr_block reviewed
- [ ] Default 0.0.0.0/1 changed (for production)
- [ ] Specific IP or network range configured
- [ ] Security requirements documented

### Cost Review
- [ ] VM size appropriate for use case
- [ ] Disk type appropriate (Premium vs Standard)
- [ ] Monthly cost estimate reviewed (~$324 default)
- [ ] Budget approved
- [ ] Cost alerts configured (optional)

### Documentation
- [ ] README.md reviewed
- [ ] QUICKREF.md bookmarked
- [ ] CONFIGURATION.md consulted
- [ ] Team notified of deployment

---

## Deployment Checklist

### Terraform Initialization
- [ ] Navigate to terraform directory: `cd terraform/`
- [ ] Run: `terraform init`
- [ ] Providers downloaded successfully
- [ ] No initialization errors

### Validation
- [ ] Run: `terraform validate`
- [ ] Configuration is valid
- [ ] No syntax errors

### Planning
- [ ] Run: `terraform plan`
- [ ] Review all resources to be created:
  - [ ] 1x Resource group
  - [ ] 1x Storage account
  - [ ] 1x Virtual network
  - [ ] 1x Subnet
  - [ ] 1x Network security group
  - [ ] 8x Public IP addresses
  - [ ] 8x Network interfaces
  - [ ] 8x Virtual machines
- [ ] No unexpected changes
- [ ] Resource names are correct

### Deployment
- [ ] Run: `terraform apply`
- [ ] Review plan one more time
- [ ] Type 'yes' to confirm
- [ ] Wait 10-15 minutes for completion
- [ ] No errors during apply

---

## Post-Deployment Checklist

### Verification
- [ ] All 8 VMs created successfully
- [ ] All public IPs allocated
- [ ] NSG created and associated
- [ ] Storage account created
- [ ] No terraform errors

### Outputs
- [ ] Run: `terraform output`
- [ ] All public IPs displayed
- [ ] SSH commands shown
- [ ] Deployment summary displayed
- [ ] Outputs saved for reference

### Connectivity
- [ ] SSH to DB LB successful
- [ ] SSH to DB1 successful
- [ ] SSH to App LB successful
- [ ] SSH to App1 successful
- [ ] No connection errors

### VM Health
- [ ] All VMs in "Running" state
- [ ] Boot diagnostics accessible
- [ ] Ubuntu 22.04 LTS confirmed
- [ ] Disk space adequate
- [ ] Network connectivity working

### Security
- [ ] NSG rules verified
- [ ] SSH key authentication working
- [ ] Password authentication disabled
- [ ] Only authorized IPs can access (if configured)
- [ ] Firewall rules appropriate

### Documentation
- [ ] Public IPs documented
- [ ] SSH commands saved
- [ ] Access procedures documented
- [ ] Team access granted
- [ ] Runbook updated

---

## Application Configuration Checklist

### Ansible Setup
- [ ] Ansible installed
- [ ] Inventory file created
- [ ] SSH keys distributed
- [ ] Test connectivity: `ansible all -m ping`
- [ ] Playbooks reviewed

### Database Configuration
- [ ] DB1 configured as lead
- [ ] DB replication set up
- [ ] Database users created
- [ ] Database backup configured
- [ ] Connection tested

### Application Configuration
- [ ] Application deployed to app servers
- [ ] Configuration files updated
- [ ] Database connection configured
- [ ] Application started
- [ ] Health checks passing

### Load Balancer Configuration
- [ ] DB LB configured
- [ ] App LB configured
- [ ] Health checks configured
- [ ] Load balancing verified
- [ ] Failover tested

---

## Monitoring Checklist

### Azure Monitor
- [ ] Boot diagnostics enabled
- [ ] Metrics collection started
- [ ] Log collection configured
- [ ] Alerts configured
- [ ] Dashboard created

### Application Monitoring
- [ ] Application logs accessible
- [ ] Error tracking configured
- [ ] Performance monitoring enabled
- [ ] Uptime monitoring configured

---

## Security Hardening Checklist

### Immediate Actions
- [ ] Update NSG to specific CIDR
- [ ] Disable root SSH access
- [ ] Configure firewall on VMs
- [ ] Update all packages
- [ ] Configure automatic updates

### Ongoing Security
- [ ] Regular security updates scheduled
- [ ] Access logs reviewed weekly
- [ ] Security scan performed
- [ ] Backup verification monthly
- [ ] Incident response plan documented

---

## Cost Management Checklist

### Initial Setup
- [ ] Cost tracking tags applied
- [ ] Budget configured
- [ ] Cost alerts set up
- [ ] Billing notifications enabled

### Ongoing Management
- [ ] Weekly cost review scheduled
- [ ] Stop schedule configured (dev/test)
- [ ] Unused resources identified
- [ ] Right-sizing reviewed monthly

---

## Backup & Recovery Checklist

### Backup Setup
- [ ] Backup policy defined
- [ ] Backup schedule configured
- [ ] Retention period set
- [ ] Test restore performed

### Disaster Recovery
- [ ] Recovery procedures documented
- [ ] Failover tested
- [ ] RTO/RPO defined
- [ ] Team trained on recovery

---

## Cleanup Checklist (when needed)

### Before Cleanup
- [ ] Data backed up
- [ ] Application stopped
- [ ] Users notified
- [ ] Approval obtained

### Cleanup Process
- [ ] Run: `./cleanup.sh`
- [ ] Confirm destruction
- [ ] Wait for completion
- [ ] Verify resources deleted

### After Cleanup
- [ ] Azure resources verified deleted
- [ ] Terraform state removed
- [ ] Documentation updated
- [ ] SSH keys secured or deleted
- [ ] Team notified

---

## Troubleshooting Checklist

If deployment fails:
- [ ] Check Azure CLI authentication
- [ ] Verify subscription quota
- [ ] Review Terraform error messages
- [ ] Check terraform.tfvars syntax
- [ ] Verify SSH key paths
- [ ] Check resource name uniqueness
- [ ] Review Azure Portal for partial resources
- [ ] Consult README.md troubleshooting section

---

**Save this checklist for each deployment!**

**Date:** __________  
**Deployed by:** __________  
**Environment:** __________  
**Notes:** __________
