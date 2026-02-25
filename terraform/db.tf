resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${var.name_prefix}-subnet-group"
  }
}

module "rds" {
  source         = "./modules/rds"
  name_prefix    = var.name_prefix
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = var.db_storage_encrypted
  storage_type          = var.db_storage_type

  db_subnet_group_name   = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids = ["${module.db_sg.security_group_id}"]

  multi_az            = var.db_multi_az
  publicly_accessible = var.db_publicly_accessible

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

}