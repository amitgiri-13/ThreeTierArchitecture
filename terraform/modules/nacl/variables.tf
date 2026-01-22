variable "vpc_id" {
  description = "VPC ID to attach the NACL"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the NACL"
  type        = list(string)
}

variable "name" {
  description = "Name tag for the NACL"
  type        = string
  default     = "custom-nacl"
}

variable "tags" {
  description = "Additional tags for NACL"
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    rule_number = number
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    rule_number = number
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
  default = []
}
