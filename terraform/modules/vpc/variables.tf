# VPC Variables
variable "vpc_name" {
  type    = string

  validation {
    condition     = length(var.vpc_name) > 0
    error_message = "vpc_name must not be empty."
  }
}

variable "vpc_cidr_block" {
  type    = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block must be a valid CIDR block."
  }
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "number_of_az" {
  type    = number

  validation {
    condition     = var.number_of_az >= 1 && var.number_of_az <= 3
    error_message = "number_of_az must be between 1 and 3."
  }
}

variable "vpc_azs" {
  type    = list(string)

  validation {
    condition     = length(var.vpc_azs) >= 1
    error_message = "vpc_azs must contain at least one availability zone."
  }
}

# Public subnets 

variable "number_of_public_subnets" {
  type    = number

  validation {
    condition     = contains([0, 1, 2, 3, 4, 6], var.number_of_public_subnets)
    error_message = "number_of_public_subnets must be one of: 0, 1, 2, 3, 4, or 6."
  }
}

variable "public_subnets_cidr_block" {
  type    = list(string)

  validation {
    condition     = alltrue([for cidr in var.public_subnets_cidr_block : can(cidrnetmask(cidr))])
    error_message = "All public_subnets_cidr_block values must be valid CIDR blocks."
  }
}

# Private subnets

variable "number_of_private_subnets" {
  type    = number

  validation {
    condition     = contains([0, 1, 2, 3, 4, 6], var.number_of_private_subnets)
    error_message = "number_of_private_subnets must be one of: 0, 1, 2, 3, 4, or 6."
  }
}

variable "private_subnets_cidr_block" {
  type    = list(string)

  validation {
    condition     = alltrue([for cidr in var.private_subnets_cidr_block : can(cidrnetmask(cidr))])
    error_message = "All private_subnets_cidr_block values must be valid CIDR blocks."
  }
}