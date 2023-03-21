variable "region" {
}

variable "registry_name" {
}

variable "env" {
}

variable "project_name" {
}

variable "tags" {
  type        = map
  default     = {}
  description = "Optional tags to add to resources"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}

variable service_port {}

# Key/Value default to prevent task definitions from stopping at runtime
variable default_secret {
  default = {
    noop: "noop"
  }
  type = map
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "dns_zone_name" {
}

variable "dns_subdomain" {

}
