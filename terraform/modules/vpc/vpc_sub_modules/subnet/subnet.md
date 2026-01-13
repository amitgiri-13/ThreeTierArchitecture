# Subnet Module

This Terraform module creates **public or private subnets** within an existing VPC and optionally associates them with a gateway (Internet Gateway) based on subnet type.

The module is designed to be **AZ-aware**, reusable, and suitable for production VPC layouts.

---

## Features

* Create multiple subnets across Availability Zones
* Supports **public** and **private** subnet types
* Automatic AZ-based subnet distribution
* Optional route table and gateway association
* Designed to work with a parent VPC module

---

## Module Inputs

### Required Inputs

| Name                | Description                                 | Type           |
| ------------------- | ------------------------------------------- | -------------- |
| `vpc_name`          | Name of the VPC (used for tagging)          | `string`       |
| `vpc_id`            | ID of the VPC where subnets will be created | `string`       |
| `subnet_cidr_block` | List of CIDR blocks for subnets             | `list(string)` |
| `subnet_az`         | List of Availability Zones                  | `list(string)` |
| `number_of_az`      | Number of Availability Zones                | `number`       |
| `number_of_subnets` | Number of subnets to create                 | `number`       |
| `subnet_type`       | Subnet type: `public` or `private`          | `string`       |

---

### Optional Inputs

| Name         | Description                                              | Type     | Default |
| ------------ | -------------------------------------------------------- | -------- | ------- |
| `gateway_id` | Gateway ID to associate with route table (IGW or NAT GW) | `string` | `null`  |

---

##  Example Usage

### Public Subnets

```hcl
module "public_subnets" {
  source = "./modules/subnet"

  vpc_name          = var.vpc_name
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr_block = var.public_subnets_cidr_block
  subnet_az         = var.vpc_azs
  number_of_az      = var.number_of_az
  number_of_subnets = var.number_of_public_subnets
  subnet_type       = "public"
  gateway_id        = aws_internet_gateway.internet_gateway.id
}
```

---

### Private Subnets

```hcl
module "private_subnets" {
  source = "./modules/subnet"

  vpc_name          = var.vpc_name
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr_block = var.private_subnets_cidr_block
  subnet_az         = var.vpc_azs
  number_of_az      = var.number_of_az
  number_of_subnets = var.number_of_private_subnets
  subnet_type       = "private"
  gateway_id        = aws_nat_gateway.nat.id
}
```

---

##  Design Notes

* Subnets are distributed across AZs using modulo indexing
* CIDR list length **must match** `number_of_subnets`
* Public subnets automatically enable `map_public_ip_on_launch`
* Route tables are created per subnet type

---

## Validations Enforced

* `number_of_subnets` must be compatible with `number_of_az`
* CIDR blocks must be valid IPv4 CIDRs
* Subnet type must be either `public` or `private`

---

## Outputs

| Name             | Description                             |
| ---------------- | --------------------------------------- |
| `subnet_ids`     | List of created subnet IDs              |
| `route_table_id` | Route table associated with the subnets |

---

##  Best Practices

* Use **1 public + 2 private subnets per AZ** for production workloads
* Pair private subnets with NAT Gateway per AZ
* Avoid hardcoding CIDRs — use `cidrsubnet` when possible

---

##  Compatibility

* Terraform ≥ 1.2
* AWS Provider ≥ 5.x

---

##  License

MIT License
