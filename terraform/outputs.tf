output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of subnet id of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of subnet id of private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateway_id" {
  description = "Nat gateway id"
  value = module.vpc.regional_nat_gateway_id
}

output "web_sg_id" {
  description = "sg_id"
  value       = module.web_sg.security_group_id
}

output "db_sg_id" {
  description = "sg_id"
  value       = module.db_sg.security_group_id
}

output "db_endpoint" {
  description = "database endpoint"
  value = module.rds.rds_endpoint
}

output "db_port" {
  description = "database port"
  value = module.rds.rds_port
}

output "alb_dns" {
  description = "Public dns of alb"
  value = module.alb.alb_dns_name
}

output "dns_record_id" {
  description = "dns record id"
  value = cloudflare_dns_record.root_dns
}
