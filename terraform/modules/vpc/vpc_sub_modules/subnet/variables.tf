variable "vpc_id" {
  description = "VPC id"
  type = string
}

variable "vpc_name" {
  description = "VPC name"
  type = string
}
variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type = list(string)
}


variable "subnet_az" {
  description = "Availability zone for subnet"
  type = list(string)
}

variable "number_of_az" {
  description = "Number of Availability zones"
  type = number

  validation {
    condition     = var.number_of_az >= 1 && var.number_of_az <= 3
    error_message = "number_of_az must be between 1 and 3."
  }
}

variable "subnet_type" {
  description = "Subnet type either 'pulic' or 'private' "
  type = string

  validation {
    condition     = contains(["public", "private"], var.subnet_type)
    error_message = "subnet_type must be one of: 'public' or 'private' "
  }
}

variable "gateway_id" {
  description = "Internet gateway id, required for public subnet"
  type = string
  default = ""
}


variable "number_of_subnets" {
  description = "Number of subnets to create"
  type        = number

  validation {
    condition     = var.number_of_subnets >= 0
    error_message = "number_of_subnets must be greater or equal to 0"
  }
}

variable "map_public_ip_on_launch" {
  description = "Auto assign public ip to instance"
  type = bool
  validation {
    condition = contains([true, false],var.map_public_ip_on_launch)
    error_message = "map_public_ip_on_launch must be  one of: 'true', 'false'"
  }
}


variable "nat_gateway_id" {
  description = "Nat gateway id"
  type = string
  default = ""
}

variable "enable_regional_natgateway" {
  description = "Enable regional nat gateway"
  type = bool
  default = false
}

variable "tags" {
  description = "Additional tags"
  type  = map(string)
  default = {}
}