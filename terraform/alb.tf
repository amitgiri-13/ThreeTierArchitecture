module "alb" {
    source = "./modules/alb"

    region = "us-east-1"
    vpc_id = module.vpc.vpc_id
    public_subnets = module.vpc.public_subnets
    alb_name = "app-alb"
    target_group_name = "app-tg"
    alb_security_group = module.alb_sg.security_group_id
}
