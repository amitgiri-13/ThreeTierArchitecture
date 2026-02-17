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


output "internet_gateway_id" {
  description = "Internet gateway id"
  value = aws_internet_gateway.internet_gateway[*].id
}

output "regional_nat_gateway_id" {
  description = "regional nat gateway id"
  value = module.nat.nat_gateway_id
}