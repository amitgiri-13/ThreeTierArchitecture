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
    condition     = contains([0, 1, 2, 3, 4, 6], var.number_of_subnets)
    error_message = "number_of_subnets must be one of: 0, 1, 2, 3, 4, or 6."
  }
}
