# Custom Network ACL Terraform Module

This Terraform module creates and manages an **AWS Network Access Control List (NACL)** and optionally associates it with one or more subnets.  
It supports configurable **ingress and egress rules**, tagging, and subnet associations.

---

## Features

- Create a custom Network ACL in a specified VPC
- Associate the NACL with multiple subnets
- Define multiple ingress and egress rules
- Support for custom naming and tagging
- Safe defaults with optional rule configuration

---

## Usage

```hcl
module "custom_nacl" {
  source = "./modules/nacl"

  vpc_id     = "vpc-0abc1234"
  subnet_ids = ["subnet-1234abcd", "subnet-5678efgh"]

  name = "app-nacl"

  tags = {
    Environment = "production"
    Owner       = "network-team"
  }

  ingress_rules = [
    {
      rule_number = 100
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
    }
  ]

  egress_rules = [
    {
      rule_number = 100
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}
```

---

## Input Variables

### `vpc_id`

| Type     | Required | Description                                         |
| -------- | -------- | --------------------------------------------------- |
| `string` | Yes    | ID of the VPC where the Network ACL will be created |

---

### `subnet_ids`

| Type           | Required | Description                                   |
| -------------- | -------- | --------------------------------------------- |
| `list(string)` |  Yes    | List of subnet IDs to associate with the NACL |

---

### `name`

| Type     | Required | Default       | Description                  |
| -------- | -------- | ------------- | ---------------------------- |
| `string` |  No     | `custom-nacl` | Name tag for the Network ACL |

---

### `tags`

| Type          | Required | Default | Description                          |
| ------------- | -------- | ------- | ------------------------------------ |
| `map(string)` | No     | `{}`    | Additional tags to apply to the NACL |

---

### `ingress_rules`

| Type           | Required | Default |
| -------------- | -------- | ------- |
| `list(object)` |  No     | `[]`    |

Ingress (inbound) rules for the NACL.

Each rule supports the following attributes:

| Field         | Type     | Description                                      |
| ------------- | -------- | ------------------------------------------------ |
| `rule_number` | `number` | Rule number (1–32766, evaluated in order)        |
| `protocol`    | `string` | Protocol (`tcp`, `udp`, `icmp`, or `-1` for all) |
| `rule_action` | `string` | `allow` or `deny`                                |
| `cidr_block`  | `string` | CIDR block to allow/deny                         |
| `from_port`   | `number` | Starting port                                    |
| `to_port`     | `number` | Ending port                                      |

---

### `egress_rules`

| Type           | Required | Default |
| -------------- | -------- | ------- |
| `list(object)` |  No     | `[]`    |

Egress (outbound) rules for the NACL.

Rule structure is identical to `ingress_rules`.

---

## Notes & Best Practices

* NACL rules are **stateless** — both ingress and egress rules are required
* Rule numbers must be **unique** and processed in ascending order
* Use `-1` for protocol and ports to allow all traffic
* Avoid overlapping or conflicting rule numbers

---

## Requirements

* Terraform `>= 1.3`
* AWS Provider `>= 5.0`

---

## License

MIT License

---