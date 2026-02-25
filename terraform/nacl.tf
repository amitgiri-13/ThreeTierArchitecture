# # Nacl for public subnet
# module "public_subnet_nacl" {
#   source = "./modules/nacl"

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.public_subnets

#   name = "${var.project_name}-public-nacl"

#   ingress_rules = [
#     {
#       rule_number = 100
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 80
#       to_port     = 80
#     },
#     {
#       rule_number = 110
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 443
#       to_port     = 443
#     },
#     {
#       rule_number = 120
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 1024
#       to_port     = 65535
#     }
#   ]

#   egress_rules = [
#     {
#       rule_number = 100
#       protocol    = "-1"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 0
#       to_port     = 0
#     }
#   ]
# }

# # Nacl for private subnet with web application instance
# module "private_subnet_web_nacl" {
#   source = "./modules/nacl"

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

#   name = "${var.project_name}-private-web-nacl"

#   ingress_rules = [
#     {
#       rule_number = 100
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = var.vpc_cidr_block
#       from_port   = 80
#       to_port     = 80
#     },
#     {
#       rule_number = 110
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = var.vpc_cidr_block
#       from_port   = 443
#       to_port     = 443
#     },
#     {
#       rule_number = 120
#       protocol    = "tcp"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 1024
#       to_port     = 65535
#     }
#   ]

#   egress_rules = [
#     {
#       rule_number = 100
#       protocol    = "-1"
#       rule_action = "allow"
#       cidr_block  = "0.0.0.0/0"
#       from_port   = 0
#       to_port     = 0
#     }
#   ]
# }

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