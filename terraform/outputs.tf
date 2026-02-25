output "network" {
  description = "All VPC and subnet related outputs"
  value = {
    vpc_id                = module.vpc.vpc_id
    public_subnets        = module.vpc.public_subnets
    private_subnets       = module.vpc.private_subnets
    nat_gateway_id        = module.vpc.regional_nat_gateway_id
    internet_gateway_id   = module.vpc.internet_gateway_id

    nacl = {
      public_subnet_nacl_id         = module.public_subnet_nacl.nacl_id
      private_subnet_web_nacl_id    = module.private_subnet_web_nacl.nacl_id
      private_subnet_db_nacl_id     = module.private_subnet_db_nacl.nacl_id
    }
  }
}

output "security_groups" {
  description = "All security groups"
  value = {
    web_sg_id = module.web_sg.security_group_id
    db_sg_id  = module.db_sg.security_group_id
    alb_sg_id = module.alb_sg.security_group_id
  }
}

output "database" {
  description = "RDS database details"
  value = {
    endpoint = module.rds.rds_endpoint
    port     = module.rds.rds_port
  }
}

output "compute" {
  description = "Auto Scaling resources"
  value = {
    asg_id             = module.asg.autoscaling_group_id
    launch_template_id = module.asg.launch_template_id
  }
}

output "load_balancer" {
  description = "ALB info"
  value = {
    dns_name = module.alb.alb_dns_name
  }
}

output "dns" {
  description = "Cloudflare DNS"
  value = {
    record_id = cloudflare_dns_record.root_dns.id
  }
}