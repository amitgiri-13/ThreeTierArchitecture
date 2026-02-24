module "db_sg" {
  source      = "./modules/sg"
  name        = "db_sg"
  description = "Security group for rds db"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Environment = "dev"
  }

  ingress_rules = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = ["${module.web_sg.security_group_id}"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
