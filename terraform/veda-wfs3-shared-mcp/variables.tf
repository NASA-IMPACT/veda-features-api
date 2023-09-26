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

variable "dns_zone_name" {
}

variable "dns_subdomain" {

}

variable "alb_protocol" {}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC to deploy into. This should come from an environment variable sourced from /.envtf.sh. See `envtf.template`"
  sensitive   = true
}

variable "private_subnet_tag" {
  type        = map
  description = "key/value that will be used by the data sources to search for the correct private subnet to add the ECS service to. defaults below are for UAH"
  default = {
    "aws-cdk:subnet-name" : "*private*"
  }
}

variable "public_subnet_tag" {
  type        = map
  description = "key/value that will be used by the data sources to search for the correct public subnet to add the ECS service to. defaults below are for UAH"
  default = {
    "aws-cdk:subnet-name" : "*public*"
  }
}
