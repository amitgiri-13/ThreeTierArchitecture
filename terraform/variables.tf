variable "db_password" {
  description = "database password"
  sensitive = true 
  type = string
}

variable "db_name" {
  description = "database name"
  type = string
}

variable "db_username" {
  description = "database username"
  type = string
}

variable "api_token" {
  description = "cloudflare api token to edit dns record of specific zone"
  type = string
}

variable "zone_id" {
  description = "cloudflare zone id"
  type = string
}
