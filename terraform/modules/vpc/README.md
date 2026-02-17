# VPC Module

##  Description

This module creates a complete AWS VPC networking foundation including:

* VPC
* Internet Gateway (optional)
* Public Subnets
* Private Subnets
* Route Tables
* Optional Regional NAT Gateway

It is designed to be modular, validated, and production-ready with built-in safety checks.

---

##  Architecture Overview

### Public Subnet Flow

```
Public Subnet
      ↓
Route Table
      ↓
Internet Gateway
      ↓
Internet
```

###  Private Subnet Flow (With NAT Enabled)

```
Private Subnet
      ↓
Route Table
      ↓
NAT Gateway
      ↓
Internet Gateway
      ↓
Internet
```

---

##  Features

* Configurable VPC CIDR
* DNS support control
* Public and Private subnet support
* Multi-AZ support (1–3 AZs)
* Optional regional NAT Gateway
* Automatic Internet Gateway creation (if public subnets exist)
* Strong variable validation
* Lifecycle preconditions for subnet limits
* Custom tagging support

---

##  Usage Example

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name       = "demo-vpc"
  vpc_cidr_block = "10.0.0.0/16"

  number_of_az = 2
  vpc_azs      = ["us-east-1a", "us-east-1b"]

  # Public subnets
  number_of_public_subnets    = 2
  public_subnets_cidr_block   = ["10.0.1.0/24", "10.0.2.0/24"]

  # Private subnets
  number_of_private_subnets   = 2
  private_subnets_cidr_block  = ["10.0.10.0/24", "10.0.20.0/24"]

  map_public_ip_on_launch     = true
  enable_regional_natgateway  = true

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}
```

---

##  Inputs

### Core VPC

| Name                   | Type           | Description                |
| ---------------------- | -------------- | -------------------------- |
| `vpc_name`             | `string`       | Name of the VPC            |
| `vpc_cidr_block`       | `string`       | VPC CIDR block             |
| `enable_dns_hostnames` | `bool`         | Enable DNS hostnames       |
| `enable_dns_support`   | `bool`         | Enable DNS resolution      |
| `number_of_az`         | `number`       | Number of AZs (1–3)        |
| `vpc_azs`              | `list(string)` | List of availability zones |
| `tags`                 | `map(string)`  | Additional tags            |

---

### Public Subnets

| Name                        | Type           | Description                    |
| --------------------------- | -------------- | ------------------------------ |
| `number_of_public_subnets`  | `number`       | Number of public subnets       |
| `public_subnets_cidr_block` | `list(string)` | CIDR blocks for public subnets |

---

### Private Subnets

| Name                         | Type           | Description                            |
| ---------------------------- | -------------- | -------------------------------------- |
| `number_of_private_subnets`  | `number`       | Number of private subnets              |
| `private_subnets_cidr_block` | `list(string)` | CIDR blocks for private subnets        |
| `enable_regional_natgateway` | `bool`         | Enable NAT Gateway for private subnets |

---

### Network Behavior

| Name                      | Type   | Description                                    |
| ------------------------- | ------ | ---------------------------------------------- |
| `map_public_ip_on_launch` | `bool` | Auto assign public IP to EC2 in public subnets |

---

##  Outputs

| Name                      | Description                |
| ------------------------- | -------------------------- |
| `vpc_id`                  | VPC ID                     |
| `public_subnets`          | List of public subnet IDs  |
| `private_subnets`         | List of private subnet IDs |
| `internet_gateway_id`     | Internet Gateway ID        |
| `regional_nat_gateway_id` | NAT Gateway ID             |

---

## Validation Rules

This module enforces:

* `number_of_az` must be between 1 and 3
* Public subnets ≤ number of AZs
* Private subnets ≤ 2 × number of AZs
* CIDR list length must match subnet count
* CIDR blocks must be valid

If validation fails, Terraform will stop during planning.

---

##  Important Notes

* Internet Gateway is created only if `number_of_public_subnets > 0`
* NAT Gateway is created only if `enable_regional_natgateway = true`
* Private subnets will not have internet access unless NAT is enabled
* Ensure subnet CIDR blocks do not overlap

---

##  Module Structure

```
modules/
 └── vpc/
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      ├── locals.tf
      └── vpc_sub_modules/
            ├── subnet/
            └── natgateway/
```

---
