resource "aws_db_instance" "db" {
  identifier = "${var.name_prefix}-rds"

  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

#-----Storage-----
  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted = var.storage_encrypted 
  storage_type = var.storage_type
  kms_key_id            = var.kms_key_id != null ? var.kms_key_id : null 

#-----Network and Access-----
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az = var.multi_az 
  publicly_accessible = var.publicly_accessible

#-----Credentials-----
  db_name = var.db_name
  username = var.db_username
  password = var.manage_master_user_password ? null : var.db_password 
  manage_master_user_password = var.manage_master_user_password ? var.manage_master_user_password : null 
  master_user_secret_kms_key_id = var.kms_key_id  != null ? var.kms_key_id : null

#-----Protection-----
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name_prefix}-rds-final-${replace(timestamp(), ":", "-")}"

#-----Backup and Maintenance-----
  backup_retention_period = var.backup_retention_period
  backup_window = var.backup_window
  maintenance_window = var.maintenance_window
  copy_tags_to_snapshot = var.copy_tags_to_snapshot

#-----Monitoring-----
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null 
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id != null ? var.performance_insights_kms_key_id : null

  tags = merge(
    {Name = "${var.name_prefix}-rds"},
    var.tags 
  )

}