variable "region" {
  description = "region for alb"
  type = string
}

variable "vpc_id" {
  description = "Existing vpc id"
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "alb_name" {
  description = "alb name"
  type = string
}

variable "target_group_name" {
  description = "target group name"
  type = string
}

variable "alb_security_group" {
  description = "security group for alb"
  type = string
}

variable "tags" {
  description = "Additional tags"
  type = map(string)
  default = {}
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type = bool
  default = false
}

