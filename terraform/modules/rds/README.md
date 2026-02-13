# AWS RDS Terraform Module

This Terraform module provisions an **Amazon RDS DB instance** with configurable storage, networking, security, backup, monitoring, and encryption settings.

It is designed to be flexible and production-ready, supporting:

* Encrypted storage (KMS)
* Multi-AZ deployments
* Automated backups
* Performance Insights
* Secrets Manager integration for master password
* Deletion protection
* Snapshot management

---


##  Usage Example

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix        = "prod"
  engine             = "postgres"
  engine_version     = "15.4"
  instance_class     = "db.t3.micro"

  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  storage_encrypted       = true
  kms_key_id              = null

  db_subnet_group_name    = "prod-db-subnet-group"
  vpc_security_group_ids  = ["sg-xxxxxxxx"]
  multi_az                = false
  publicly_accessible     = false

  db_name                 = "appdb"
  db_username             = "admin"
  db_password             = "StrongPassword123!"
  manage_master_user_password = null

  deletion_protection     = true
  skip_final_snapshot     = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  copy_tags_to_snapshot   = true

  performance_insights_enabled           = true
  performance_insights_retention_period  = 7
  performance_insights_kms_key_id        = null

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

---

##  Features

### Storage Configuration

* Configurable allocated storage
* Optional autoscaling storage (`max_allocated_storage`)
* Encrypted storage using KMS
* Flexible storage type (gp2, gp3, io1, etc.)

### Network & Access

* Custom DB subnet group
* VPC security group association
* Multi-AZ deployment support
* Public or private accessibility

### Credentials Management

* Supports:

  * Manual password management
  * AWS-managed master password via Secrets Manager
* Optional KMS key for secret encryption

### Protection & Snapshots

* Deletion protection support
* Final snapshot on deletion
* Timestamp-based unique snapshot naming

### Backup & Maintenance

* Configurable backup retention period
* Custom backup window
* Custom maintenance window
* Tag copying to snapshots

### Monitoring

* Performance Insights
* Custom retention period
* Dedicated KMS key for insights

---


##  Inputs

| Variable                              | Description                             | Type         |
| ------------------------------------- | --------------------------------------- | ------------ |
| name_prefix                           | Prefix for RDS identifier and snapshots | string       |
| engine                                | Database engine (postgres, mysql, etc.) | string       |
| engine_version                        | Database engine version                 | string       |
| instance_class                        | RDS instance class                      | string       |
| allocated_storage                     | Initial storage in GB                   | number       |
| max_allocated_storage                 | Max storage autoscaling limit           | number       |
| storage_type                          | Storage type (gp2, gp3, io1)            | string       |
| storage_encrypted                     | Enable storage encryption               | bool         |
| kms_key_id                            | KMS key for storage encryption          | string       |
| db_subnet_group_name                  | DB subnet group name                    | string       |
| vpc_security_group_ids                | List of security groups                 | list(string) |
| multi_az                              | Enable Multi-AZ                         | bool         |
| publicly_accessible                   | Public accessibility flag               | bool         |
| db_name                               | Initial database name                   | string       |
| db_username                           | Master username                         | string       |
| db_password                           | Master password (if not managed)        | string       |
| manage_master_user_password           | Use AWS Secrets Manager                 | bool         |
| deletion_protection                   | Prevent accidental deletion             | bool         |
| skip_final_snapshot                   | Skip final snapshot on delete           | bool         |
| backup_retention_period               | Days to retain backups                  | number       |
| backup_window                         | Backup window                           | string       |
| maintenance_window                    | Maintenance window                      | string       |
| copy_tags_to_snapshot                 | Copy tags to snapshots                  | bool         |
| performance_insights_enabled          | Enable Performance Insights             | bool         |
| performance_insights_retention_period | PI retention days                       | number       |
| performance_insights_kms_key_id       | KMS key for PI                          | string       |
| tags                                  | Additional tags                         | map(string)  |

---

## Outputs 

| Output Name    | Description                                         |
| -------------- | --------------------------------------------------- |
| `rds_endpoint` | Full connection endpoint including address and port |
| `rds_port`     | Database port number                                |
| `rds_arn`      | Amazon Resource Name of the RDS instance            |
| `rds_id`       | RDS instance identifier                             |
| `rds_address`  | DNS hostname of the RDS instance                    |

These outputs can be used by other modules (e.g., application, EKS, ECS, or Lambda modules) to configure database connectivity.

---

## Security Notes

* Prefer `manage_master_user_password = true` for production.
* Avoid hardcoding database passwords.
* Use private subnets unless public access is explicitly required.
* Always enable encryption in production.
* Enable deletion protection in production environments.

---

##  Recommended Production Settings

* `multi_az = true`
* `storage_encrypted = true`
* `deletion_protection = true`
* `skip_final_snapshot = false`
* `backup_retention_period >= 7`

---
