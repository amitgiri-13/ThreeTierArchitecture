module "alb" {
  source = "./modules/alb"

  region             = var.region
  vpc_id             = module.vpc.vpc_id
  public_subnets     = module.vpc.public_subnets
  alb_name           = "${var.project_name}-alb"
  target_group_name  = "${var.project_name}-tg"
  alb_security_group = module.alb_sg.security_group_id
}
