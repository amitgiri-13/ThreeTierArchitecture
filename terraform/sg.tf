# Security group for application load balancer
module "alb_sg" {
  source      = "./modules/sg"
  name        = "${var.project_name}-alb_sg"
  description = "Security group for alb"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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

# Security group for web application (ec2)
module "web_sg" {
  source      = "./modules/sg"
  name        = "${var.project_name}-web_sg"
  description = "Security group for web server"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = ["${module.alb_sg.security_group_id}"]
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = ["${module.alb_sg.security_group_id}"]
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

# Security group for rds instance
module "db_sg" {
  source      = "./modules/sg"
  name        = "${var.project_name}-db_sg"
  description = "Security group for rds db"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags

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
      cidr_blocks = ["${var.vpc_cidr_block}"]
    }
  ]
}


