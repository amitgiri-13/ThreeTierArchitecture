# NAT Gateway Module

##  Description

This module creates a **regional AWS NAT Gateway** inside an existing VPC.

It allows private subnets to access the internet securely via a NAT Gateway.
The NAT Gateway is created only if explicitly enabled.

---

##  Features

* Optional creation using `enable_regional_nat_gateway`
* Accepts external VPC ID
* Supports custom tags
* Outputs NAT Gateway ID

---

##  Usage Example

```hcl
module "nat_gateway" {
  source = "./modules/nat"

  vpc_id                       = module.vpc.vpc_id
  enable_regional_nat_gateway  = true

  tags = {
    Name        = "project-nat"
    Environment = "dev"
  }
}
```

You can then pass the NAT ID to other modules:

```hcl
nat_gateway_id = module.nat_gateway.nat_gateway_id[0]
```

(Only if NAT is enabled)

---

##  Inputs

| Name                          | Description                      | Type          | Default | Required |
| ----------------------------- | -------------------------------- | ------------- | ------- | -------- |
| `vpc_id`                      | VPC ID where NAT will be created | `string`      | —       | Yes      |
| `enable_regional_nat_gateway` | Enable/disable NAT creation      | `bool`        | `false` | No       |
| `tags`                        | Additional resource tags         | `map(string)` | `{}`    | No       |

---

##  Outputs

| Name             | Description       | Type           |
| ---------------- | ----------------- | -------------- |
| `nat_gateway_id` | NAT Gateway ID(s) | `list(string)` |

---

##  Notes

* When `enable_regional_nat_gateway = false`, no NAT Gateway is created.
* Output will return an empty list `[]` if NAT is disabled.
* This module creates a **regional NAT Gateway**, not per-AZ.

---
