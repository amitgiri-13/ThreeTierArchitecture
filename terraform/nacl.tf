# Nacl for private subnet with rds instances
module "private_subnet_db_nacl" {
  source = "./modules/nacl"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]

  name = "${var.project_name}-private-db-nacl"

  ingress_rules = [
    {
      rule_number = 100
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr_block
      from_port   = 3306
      to_port     = 3306
    },
    {
      rule_number = 110
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr_block
      from_port   = 1024
      to_port     = 65535
    }
  ]

  egress_rules = [
    {
      rule_number = 100
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr_block
      from_port   = 0
      to_port     = 0
    }
  ]
}