variable "region" {
}

variable "registry_name" {
}

variable "env" {
}

variable "project_name" {
}

variable "tags" {
  type        = map(any)
  default     = {"project": "ghgc", "service": "ghgc-features-api-dev"}
  description = "Optional tags to add to resources"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
  default = ["us-west-2a", "us-west-2b"]
}

variable "service_port" {
  default = 8080
}

# Key/Value default to prevent task definitions from stopping at runtime
variable "default_secret" {
  default = {
    noop : "noop"
  }
  type = map(any)
}

# variable "db_password" {
#   description = "RDS root user password"
#   type        = string
#   sensitive   = true
# }

variable "dns_zone_name" {
  default = null
}

variable "dns_subdomain" {
  default = null
}

variable "alb_protocol" {
  default = "HTTP"
}

variable "vpc_id" {}
variable "permissions_boundary_policy_name" {
  default = ""
}