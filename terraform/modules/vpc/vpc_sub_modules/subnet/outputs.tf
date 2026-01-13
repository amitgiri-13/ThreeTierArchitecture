output "subnets_id" {
    description = "Subnet id"
    value = aws_subnet.subnet[*].id
}

output "aws_route_table_id" {
    description = "Route table id"
    value = aws_route_table.route_table[*].id
}


