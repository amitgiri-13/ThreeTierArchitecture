variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "tags"
  type        = map(string)
}

# Launch Template Variables
variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "block_device_name" {
  description = "Block device name"
  type = string
  default = "/dev/xvda" # for amazon linux 2
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"
}

variable "delete_on_termination" {
  description = "Root volume, delete on termination"
  type = bool
  default = true 
}

# Auto Scaling Group Variables
variable "min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "enabled_metrics" {
  description = "List of metrics to enable for ASG"
  type        = list(string)
  default = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupTotalInstances"
  ]
}
