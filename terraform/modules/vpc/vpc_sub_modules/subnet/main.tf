resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_block[count.index]
  availability_zone       = var.subnet_az[count.index % var.number_of_az ] 
  map_public_ip_on_launch = var.subnet_type == "public"
  count = var.number_of_subnets

  tags = {
    Name = "${var.vpc_name}-subnet-${var.subnet_type}-${count.index }-${var.subnet_az[count.index % var.number_of_az]}"
    Type = var.subnet_type
  }
}


resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  count = var.number_of_subnets

  tags = {
    Name = "${var.vpc_name}-rtb-${var.subnet_type}-${count.index}"
  }
}

resource "aws_route" "internet_route" {
  count = var.subnet_type == "public" && var.number_of_subnets > 0 ? 1 : 0

  route_table_id         = aws_route_table.route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
}


resource "aws_route_table_association" "route_table_association" {
  count = var.number_of_subnets
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table[count.index].id
}