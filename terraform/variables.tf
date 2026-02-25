#--------------------------------
# Project common variables
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = { Env = "dev" }
}

#---------------------------------
# Vpc variables
#---------------------------------
variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "number_of_az" {
  description = "Number of az"
  type        = number
  default     = 2
}

variable "vpc_azs" {
  description = "List of azs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "number_of_public_subnets" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "public_subnets_cidr_block" {
  description = "List of cidr block for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "map_public_ip_on_launch" {
  description = "map public ip on launch"
  type        = bool
  default     = false
}

variable "number_of_private_subnets" {
  description = "Number of private subnets"
  type        = number
  default     = 4
}

variable "private_subnets_cidr_block" {
  description = "List of cidr block for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "enable_regional_natgateway" {
  description = "regional natfateway"
  type        = bool
  default     = true
}


#------------------------------
# auto scaling group  variables
#------------------------------
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
  default     = "privatekey"
}

variable "user_data" {
  description = "Path to user data script"
  type        = string
  default     = "./userdata.sh"
}

variable "block_device_name" {
  description = "Block device name"
  type        = string
  default     = "/dev/xvda"
}

variable "root_volume_size" {
  description = "root volume size"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "root volume type"
  type        = string
  default     = "gp2"
}

variable "asg_min_size" {
  description = "asg minimum size"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "asg maximum size"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "asg desired capacity"
  type        = number
  default     = 1
}

variable "health_check_type" {
  description = "asg health check type"
  type        = string
  default     = "Ec2"
}

#-----------------------------
# RDS variables
#----------------------------
variable "name_prefix" {
  description = "rds name prefix"
  type        = string
  default     = "mydb"
}

variable "db_engine" {
  description = "rds engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "rds engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "rds instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "rds allocated storage"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "rds max allocated storage"
  type        = number
  default     = 50
}

variable "db_storage_encrypted" {
  description = "rds storage encryption"
  type        = bool
  default     = true
}

variable "db_storage_type" {
  description = "rds storage type"
  type        = string
  default     = "gp2"
}

variable "db_multi_az" {
  description = "rds multi az support"
  type        = bool
  default     = false
}

variable "db_publicly_accessible" {
  description = "rds publically accessible"
  type        = bool
  default     = false
}

# Required 
variable "db_password" {
  description = "database password"
  sensitive   = true
  type        = string
}

variable "db_name" {
  description = "database name"
  type        = string
}

variable "db_username" {
  description = "database username"
  type        = string
}


#----------------------------------
# Cloudflare dns records variable
#----------------------------------
variable "api_token" {
  description = "cloudflare api token to edit dns record of specific zone"
  type        = string
}

variable "zone_id" {
  description = "cloudflare zone id"
  type        = string
}


