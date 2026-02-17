resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name  = var.vpc_name
    },
    var.tags
  )

  lifecycle {
    precondition {
      condition     = local.valid_public_subnets && local.valid_private_subnets
      error_message = <<EOT
                      Invalid subnet configuration:

                      - number_of_az              = ${var.number_of_az}
                      - number_of_public_subnets  must be between 0 and ${local.max_public_subnets}
                      - number_of_private_subnets must be between 0 and ${local.max_private_subnets}

                      Rule:
                      - Public  subnets ≤ AZs
                      - Private subnets ≤ 2 × AZs
                    EOT
    }

    precondition {
      condition     = length(var.public_subnets_cidr_block) == var.number_of_public_subnets && length(var.private_subnets_cidr_block) == var.number_of_private_subnets
      error_message = "Subnet CIDR count must match subnet count variables."
    }
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  count = var.number_of_public_subnets == 0 ? 0 : 1

  tags = merge(
  {
    Name = "${var.vpc_name}-igw"
  },
  var.tags
  )
}


module "public_subnets" {
  source = "./vpc_sub_modules/subnet"

  vpc_name          = var.vpc_name
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr_block = var.public_subnets_cidr_block
  subnet_az         = var.vpc_azs
  number_of_az      = var.number_of_az
  number_of_subnets = var.number_of_public_subnets
  subnet_type       = "public"
  gateway_id        = var.number_of_public_subnets > 0 ?  aws_internet_gateway.internet_gateway[0].id : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = var.tags
}

module "private_subnets" {
  source = "./vpc_sub_modules/subnet"

  vpc_name          = var.vpc_name
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr_block = var.private_subnets_cidr_block
  subnet_az         = var.vpc_azs
  number_of_az      = var.number_of_az
  number_of_subnets = var.number_of_private_subnets
  subnet_type       = "private"
  map_public_ip_on_launch = "false" 
  nat_gateway_id = var.enable_regional_natgateway ? module.nat.nat_gateway_id[0] : null
  enable_regional_natgateway = var.enable_regional_natgateway 

  tags = var.tags 
}


module "nat" {
  source = "./vpc_sub_modules/natgateway"

  enable_regional_nat_gateway = var.enable_regional_natgateway
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    { 
      Name = "${var.vpc_name}-nat-gateway"
    },
    var.tags 
  )

} 

