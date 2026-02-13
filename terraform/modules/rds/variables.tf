variable "name_prefix" {
  description = "Prefix to use for resource names (e.g. 'app-prod')"
  type        = string
}

variable "engine" {
  description = "Database engine type (mysql, postgres, mariadb, oracle-se2, sqlserver-ex, etc.)"
  type        = string
  validation {
   condition     = contains(["mysql", "postgres", "mariadb", "aurora-mysql", "aurora-postgresql"], var.engine)
     error_message = "Unsupported engine type."
 }
}

variable "engine_version" {
  description = "Version of the database engine (e.g. '8.0.32', '15.5')"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class (e.g. db.t4g.medium, db.m6g.large, db.r6g.xlarge)"
  type        = string
  default     = "db.t4g.medium"
}

# ─── Storage ────────────────────────────────────────────────────────────────

variable "allocated_storage" {
  description = "Initial allocated storage size in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit in GiB for RDS storage autoscaling (0 = disabled)"
  type        = number
  default     = 0
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption at rest"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Type of storage (standard, gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "kms_key_id" {
  description = "ARN of KMS key to use for storage encryption (null = AWS-managed key)"
  type        = string
  default     = null
}

# ─── Network & Access ───────────────────────────────────────────────────────

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group to place the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate"
  type        = list(string)
}

variable "multi_az" {
  description = "Deploy instance in multiple Availability Zones for high availability"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Whether the DB instance is internet-facing (almost always false in production)"
  type        = bool
  default     = false
}

# ─── Credentials ────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = null
}

variable "db_username" {
  description = "Master username for the DB instance"
  type        = string
}

variable "manage_master_user_password" {
  description = "Manage master user password with secrets manager"
  type = bool
  default = false 
}

variable "db_password" {
  description = "Master password for the DB instance (sensitive)"
  type        = string
  sensitive   = true
}

# ─── Protection ─────────────────────────────────────────────────────────────

variable "deletion_protection" {
  description = "Enable deletion protection (prevents accidental destroy)"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip creation of final snapshot when deleting the instance"
  type        = bool
  default     = false
}


# ─── Backup & Maintenance ───────────────────────────────────────────────────

variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0–35)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily time range for backups (UTC) — format: 'hh24:mi-hh24:mi' (e.g. '03:00-04:00')"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance (UTC) — format: 'ddd:hh24:mi-ddd:hh24:mi'"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copy all instance tags to snapshots"
  type        = bool
  default     = true
}

# ─── Monitoring ─────────────────────────────────────────────────────────────

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Retention period for Performance Insights data (7, 731, or multiples of 31 up to 731)"
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ARN for encrypting Performance Insights data (null = AWS-owned key)"
  type        = string
  default     = null
}

# ─── Tags ───────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Additional tags to apply to the RDS instance"
  type        = map(string)
  default     = {}
}