# VPC Terraform Module

This Terraform module creates an **AWS VPC** with configurable **Availability Zones, public subnets, private subnets**, and an **Internet Gateway**, using a reusable subnet sub-module.

The module enforces **AZ-aware subnet limits** and validates CIDR and subnet counts at plan time to prevent invalid network layouts.

---

##  Features

* Creates an AWS VPC with DNS support options
* AZ-aware validation for public and private subnets
* Supports **0–N public** and **0–2N private** subnets (where N = AZ count)
* Automatically creates Internet Gateway when public subnets exist
* Uses a reusable subnet sub-module for clean separation of concerns
* Fails early with clear error messages using `precondition`

---

##  Module Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  # VPC
  vpc_name       = "terraformVPC"
  vpc_cidr_block = "10.0.0.0/16"

  # Availability Zones
  number_of_az = 1
  vpc_azs      = ["us-east-1a"]

  # Public Subnets
  number_of_public_subnets  = 1
  public_subnets_cidr_block = ["10.0.0.0/24"]

  # Private Subnets
  number_of_private_subnets  = 2
  private_subnets_cidr_block = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

---

##  Inputs

### VPC

| Name                   | Description            | Type     | Required |
| ---------------------- | ---------------------- | -------- | -------- |
| `vpc_name`             | Name of the VPC        | `string` | yes      |
| `vpc_cidr_block`       | CIDR block for the VPC | `string` | yes      |
| `enable_dns_support`   | Enable DNS support     | `bool`   | no       |
| `enable_dns_hostnames` | Enable DNS hostnames   | `bool`   | no       |

---

### Availability Zones

| Name           | Description                  | Type           | Required |
| -------------- | ---------------------------- | -------------- | -------- |
| `number_of_az` | Number of Availability Zones | `number`       | yes      |
| `vpc_azs`      | List of AZs to use           | `list(string)` | yes      |

---

### Public Subnets

| Name                        | Description                    | Type           | Required |
| --------------------------- | ------------------------------ | -------------- | -------- |
| `number_of_public_subnets`  | Number of public subnets       | `number`       | yes      |
| `public_subnets_cidr_block` | CIDR blocks for public subnets | `list(string)` | yes      |

---

### Private Subnets

| Name                         | Description                     | Type           | Required |
| ---------------------------- | ------------------------------- | -------------- | -------- |
| `number_of_private_subnets`  | Number of private subnets       | `number`       | yes      |
| `private_subnets_cidr_block` | CIDR blocks for private subnets | `list(string)` | yes      |

---

##  Validations & Rules

The module enforces the following rules during `terraform plan`:

### Subnet-to-AZ Rules

For `number_of_az = N`:

* Public subnets: `0 ≤ public ≤ N`
* Private subnets: `0 ≤ private ≤ 2 × N`

### CIDR Consistency

* Length of `public_subnets_cidr_block` **must equal** `number_of_public_subnets`
* Length of `private_subnets_cidr_block` **must equal** `number_of_private_subnets`

If these rules are violated, Terraform will fail with a clear error message.

---

## Resources Created

* `aws_vpc`
* `aws_internet_gateway` (only if public subnets > 0)
* Public subnets (via subnet sub-module)
* Private subnets (via subnet sub-module)
* Route tables and associations (inside subnet module)

---

##  Outputs

| Name                 | Description                |
| -------------------- | -------------------------- |
| `vpc_id`             | ID of the created VPC      |
| `public_subnet_ids`  | List of public subnet IDs  |
| `private_subnet_ids` | List of private subnet IDs |

---

##  Design Notes

* Subnet creation logic is delegated to a dedicated subnet module
* Internet Gateway is conditionally created only when needed
* Designed to scale cleanly from 1 AZ to multi-AZ architectures

---

##  Best Practices

* Use **1 public + 2 private subnets per AZ** for production workloads
* Use separate route tables for public and private subnets
* Add NAT Gateways per AZ for high availability (future extension)

---

##  Compatibility

* Terraform ≥ 1.2
* AWS Provider ≥ 5.x

---

##  License

MIT License
