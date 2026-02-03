# Terraform AWS Security Group Module

A simple Terraform module to create an **AWS Security Group** with configurable ingress and egress rules.

---

## Usage

```hcl
module "sg" {
  source = "./modules/security-group"

  name   = "example-sg"
  vpc_id = aws_vpc.main.id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

---

## Inputs

| Name            | Description                 | Required |
| --------------- | --------------------------- | -------- |
| `name`          | Name of the security group  | Yes    |
| `description`   | Security group description  | No     |
| `vpc_id`        | VPC ID where SG is created  | Yes    |
| `tags`          | Tags for the security group | No     |
| `ingress_rules` | List of ingress rules       | No     |
| `egress_rules`  | List of egress rules        | No     |

---

## Rule Format

```hcl
{
  from_port        = number
  to_port          = number
  protocol         = string
  cidr_blocks      = optional(list(string))
  ipv6_cidr_blocks = optional(list(string))
  description      = optional(string)
}
```

---

## Notes

* `name` and `vpc_id` are required
* Ingress and egress rules are optional
* Supports IPv4 and IPv6 CIDR blocks
* Suitable for EC2, ALB, RDS, and other AWS resources

---

