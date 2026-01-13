output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.vpc.id
}

output "public_subnets" {
  description = "List of subnet id of public subnets"
  value       = module.public_subnets.subnets_id
}

output "private_subnets" {
  description = "List of subnet id of private subnets"
  value       = module.private_subnets.subnets_id
}

