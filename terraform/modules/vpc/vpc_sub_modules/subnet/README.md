# Subnet Module

##  Description

This module creates:

* Multiple **AWS Subnets**
* Individual **Route Tables**
* Internet or NAT routes (based on subnet type)
* Route Table associations

It supports both:

*  Public Subnets (via Internet Gateway)
*  Private Subnets (via NAT Gateway)

The module is flexible and supports up to **3 Availability Zones**.

---

##  Features

* Create multiple subnets dynamically
* Supports public or private subnet type
* Automatic route table creation per subnet
* Internet Gateway route for public subnets
* NAT Gateway route for private subnets
* Subnet-to-route-table association
* Custom tagging support

---

##  Usage Example

###  Public Subnets

```hcl
module "public_subnets" {
  source = "./modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  vpc_name                = "my-vpc"
  subnet_type             = "public"

  subnet_cidr_block       = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_az               = ["us-east-1a", "us-east-1b"]
  number_of_az            = 2
  number_of_subnets       = 2

  map_public_ip_on_launch = true
  gateway_id              = module.igw.internet_gateway_id

  tags = {
    Environment = "dev"
  }
}
```

---

###  Private Subnets (With NAT)

```hcl
module "private_subnets" {
  source = "./modules/subnet"

  vpc_id                    = module.vpc.vpc_id
  vpc_name                  = "my-vpc"
  subnet_type               = "private"

  subnet_cidr_block         = ["10.0.10.0/24", "10.0.20.0/24"]
  subnet_az                 = ["us-east-1a", "us-east-1b"]
  number_of_az              = 2
  number_of_subnets         = 2

  map_public_ip_on_launch   = false

  enable_regional_natgateway = true
  nat_gateway_id            = module.nat_gateway.nat_gateway_id[0]

  tags = {
    Environment = "dev"
  }
}
```

---

##  Inputs

| Name                         | Description                       | Type           | Default | Required |
| ---------------------------- | --------------------------------- | -------------- | ------- | -------- |
| `vpc_id`                     | VPC ID                            | `string`       | —       | Yes      |
| `vpc_name`                   | VPC Name                          | `string`       | —       | Yes      |
| `subnet_cidr_block`          | List of subnet CIDR blocks        | `list(string)` | —       | Yes      |
| `subnet_az`                  | List of availability zones        | `list(string)` | —       | Yes      |
| `number_of_az`               | Number of AZs (1–3)               | `number`       | —       | Yes      |
| `subnet_type`                | `public` or `private`             | `string`       | —       | Yes      |
| `gateway_id`                 | Internet Gateway ID (public only) | `string`       | `""`    | No       |
| `number_of_subnets`          | Number of subnets                 | `number`       | —       | Yes      |
| `map_public_ip_on_launch`    | Auto assign public IP             | `bool`         | —       | Yes      |
| `nat_gateway_id`             | NAT Gateway ID (private only)     | `string`       | `""`    | No       |
| `enable_regional_natgateway` | Enable NAT routing                | `bool`         | `false` | No       |
| `tags`                       | Additional tags                   | `map(string)`  | `{}`    | No       |

---

##  Outputs

| Name                 | Description             | Type           |
| -------------------- | ----------------------- | -------------- |
| `subnets_id`         | List of subnet IDs      | `list(string)` |
| `aws_route_table_id` | List of route table IDs | `list(string)` |

---

##  Routing Logic

### Public Subnet

```
Subnet → Route Table → 0.0.0.0/0 → Internet Gateway
```

### Private Subnet

```
Subnet → Route Table → 0.0.0.0/0 → NAT Gateway
```

---

##  Important Notes

* Ensure `number_of_subnets` matches the length of `subnet_cidr_block`
* NAT route is created only if:

  * `subnet_type = "private"`
  * `enable_regional_natgateway = true`
* Internet route is created only if:

  * `subnet_type = "public"`

---