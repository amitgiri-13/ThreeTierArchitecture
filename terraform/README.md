# Terraform AWS Infrastructure Overview

**Project:** Scalable Multi-Tier Web Application on AWS  
**Description:** This Terraform configuration provisions a complete, production-ready AWS environment including VPC networking, security layers (SG + NACL), Application Load Balancer, Auto Scaling Group with EC2 instances, RDS database, and DNS management. The project follows a modular design for reusability and maintainability.

## Table of Contents

- [Root Configuration Files](#root-configuration-files)
- [Modules](#modules)
- [Deployment](#deployment)
- [Additional Resources](#additional-resources)

## Root Configuration Files

| File / Directory              | Description |
|-------------------------------|-------------|
| [alb.tf](./alb.tf)            | Calls the `alb` module to create Application Load Balancer, listeners, target groups, and health checks. |
| [asg.tf](./asg.tf)            | Calls the `asg` module to provision Launch Template and Auto Scaling Group (with scaling policies). |
| [db.tf](./db.tf)              | Calls the `rds` module to deploy managed database (RDS instance + subnet group + security). |
| [dns.tf](./dns.tf)            | Manages DNS resources (typically Route 53 records pointing to ALB). |
| [nacl.tf](./nacl.tf)          | Calls the `nacl` module to apply Network ACL rules at the subnet level. |
| [outputs.tf](./outputs.tf)    | Exports important values (ALB DNS name, RDS endpoint, VPC ID, etc.). |
| [sg.tf](./sg.tf)              | Calls the `sg` module to create Security Groups for ALB, ASG instances, RDS, etc. |
| [vpc.tf](./vpc.tf)            | Calls the `vpc` module to build the entire networking foundation (VPC, subnets, IGW, NAT, route tables). |
| [variables.tf](./variables.tf) | Declares all input variables used across the project. |
| [variables.tfvars](./variables.tfvars) | Variable values file (non-sensitive defaults; use secrets manager for production). |
| [userdata.sh](./userdata.sh)  | Bootstrap script passed to EC2 instances via Launch Template. |

## Modules

All modules are self-contained with their own `main.tf`, `variables.tf`, `outputs.tf` and dedicated `README.md`.

| Module Path | Purpose | Key Resources |
|-------------|---------|---------------|
| [modules/alb/](./modules/alb/) | Application Load Balancer | ALB, target groups, listeners, security group integration. |
| [modules/asg/](./modules/asg/) | Auto Scaling Group | Launch template + ASG (with health checks and scaling). |
| [modules/nacl/](./modules/nacl/) | Network ACLs | Subnet-level stateless firewall rules. |
| [modules/rds/](./modules/rds/) | Relational Database Service | RDS instance, DB subnet group, parameter group. |
| [modules/sg/](./modules/sg/) | Security Groups | Fine-grained stateful firewall rules for each tier. |
| [modules/vpc/](./modules/vpc/) | Core VPC Networking | VPC, Internet Gateway, route tables, plus **two sub-modules**: |
| [modules/vpc/vpc_sub_modules/subnet/](./modules/vpc/vpc_sub_modules/subnet/) | Subnet provisioning | Public & private subnets with proper tagging. |
| [modules/vpc/vpc_sub_modules/natgateway/](./modules/vpc/vpc_sub_modules/natgateway/) | NAT Gateway | Enables outbound internet from private subnets. |

> Click any module path above to navigate directly to the folder. Each module also contains its own detailed `README.md`.

## Deployment

```bash
# 1. Initialize
terraform init

# 2. Validate & Plan
terraform validate
terraform plan -var-file=variables.tfvars

# 3. Apply
terraform apply -var-file=variables.tfvars
```

**Recommended workflow:**  
`terraform plan` → review → `terraform apply`

## Additional Resources

- Individual module READMEs for deeper configuration details.

---

**Maintainers:** Update this README when new root files or modules are added.  
**Best Practice:** Keep modules loosely coupled and use remote state (S3 + DynamoDB) for team environments.

Happy Terraforming! 
---
