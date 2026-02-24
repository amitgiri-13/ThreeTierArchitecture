module "web_sg" {
  source      = "./modules/sg"
  name        = "web_sg"
  description = "Security group for web server"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Environment = "dev"
  }

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_groups = ["${module.alb_sg.security_group_id}"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
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
