module "vpc" {

  source = "./modules/vpc"
  # vpc
  vpc_name       = "terraformVPC"
  vpc_cidr_block = "10.0.0.0/16"

  # az 
  number_of_az = 2
  vpc_azs      = ["us-east-1a", "us-east-1b"]

  # public subnets
  number_of_public_subnets  = 2
  public_subnets_cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
  map_public_ip_on_launch   = true


  # private subnets
  number_of_private_subnets  = 4
  private_subnets_cidr_block = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

  enable_regional_natgateway = true

  tags = { 
    Environment = "dev"
  }
}


