locals {
  max_public_subnets  = var.number_of_az
  max_private_subnets = var.number_of_az * 2

  valid_public_subnets = var.number_of_public_subnets >= 0 && var.number_of_public_subnets <= local.max_public_subnets

  valid_private_subnets = var.number_of_private_subnets >= 0 && var.number_of_private_subnets <= local.max_private_subnets
}
