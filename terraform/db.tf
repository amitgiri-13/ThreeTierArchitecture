resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "db-subnet-group"
  }
}

module "rds" {
  source = "./modules/rds"
  name_prefix = "mydb"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  max_allocated_storage = 50
  storage_encrypted = true 
  storage_type = "gp3"

  db_subnet_group_name = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids = ["${module.db_sg.security_group_id}"]

  multi_az = false 
  publicly_accessible = false 

  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password

}