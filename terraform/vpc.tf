module "vpc" {

  source = "./modules/vpc"
  # vpc
  vpc_name       = "${var.project_name}-vpc"
  vpc_cidr_block = var.vpc_cidr_block

  # az 
  number_of_az = var.number_of_az
  vpc_azs      = var.vpc_azs

  # public subnets
  number_of_public_subnets  = var.number_of_public_subnets
  public_subnets_cidr_block = var.public_subnets_cidr_block
  map_public_ip_on_launch   = var.map_public_ip_on_launch


  # private subnets
  number_of_private_subnets  = var.number_of_private_subnets
  private_subnets_cidr_block = var.private_subnets_cidr_block

  enable_regional_natgateway = var.enable_regional_natgateway

  tags = var.tags
}


