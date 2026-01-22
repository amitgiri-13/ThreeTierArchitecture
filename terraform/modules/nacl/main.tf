resource "aws_network_acl" "nacl" {
    vpc_id = var.vpc_id

    tags = merge (
        { Name = var.name },
        var.tags
    )
}

resource "aws_network_acl_rule" "ingress" {
    for_each = { for rule in var.ingress_rules: rule.rule_number => rule }
    network_acl_id = aws_network_acl.nacl.id
    rule_number = each.value.rule_number
    protocol = each.value.protocol
    rule_action = each.value.rule_action
    egress = false 
    cidr_block = each.value.cidr_block
    from_port = each.value.from_port
    to_port = each.value.to_port
}

resource "aws_network_acl_rule" "egress" {
  for_each      = { for rule in var.egress_rules : rule.rule_number => rule }
  network_acl_id = aws_network_acl.nacl.id
  rule_number    = each.value.rule_number
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  egress         = true
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_association" "network_acl_association" {
  count = length(var.subnet_ids)
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = var.subnet_ids[count.index]
}
