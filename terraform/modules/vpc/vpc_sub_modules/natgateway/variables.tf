variable "vpc_id" {
  description = "vpc id"
  type  = string 
}

variable "enable_regional_nat_gateway" {
  description = "enable regional nat gateway"
  type = bool 
  default = false
}

variable "tags" {
  description = "Additional tags"
  type = map(string)
}