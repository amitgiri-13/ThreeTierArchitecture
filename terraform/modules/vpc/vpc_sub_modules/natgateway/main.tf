resource "aws_nat_gateway" "nat" {
  vpc_id            = var.vpc_id
  availability_mode = "regional"
  count = var.enable_regional_nat_gateway ? 1 : 0
  tags = merge(
    var.tags
  )
}