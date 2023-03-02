variable "environment" {}
variable "region" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(any)
}

variable "tags" {
  type    = map
  default = {}
}

variable "service_name" {}
variable "service_port" {}

variable "service_protocol" {
  type    = string
  default = "tcp"
}

variable "cpu" {
  default = 512
}

variable "memory" {
  default = 1024
}

variable "instance_count" {
  default = 1
}

variable "log_retention_days" {
  default = 90
}

variable "container_command" {
  type        = list
  default     = []
  description = "Command to execute in the container in list format (ex: ['executable','param1','param2']). Pass an empty string to use the container default."
}

variable "container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "A list of mappings of 'name' and 'valueFrom' (Secrets Manager ARNs) to insert into the container environment"
}

variable "container_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of mappings of 'name' and 'value' to insert into the container environment"
}

variable "container_working_directory" {
  default     = ""
  description = "Working directory for the container. Pass an empty string to use the container default."
}

variable "container_ingress_cidrs" {
  type = set(string)
}

variable "container_ingress_sg_ids" {
  type = set(string)
}

variable "additional_sg_ingress_rules_for_vpc_default_sg" {
  #################################################
  # EXAMPLE
  #################################################
  #  [
  #    {
  #      primary_key       = "1"
  #      vpc_default_sg_id = "${module.networking.vpc_default_sg_id}"
  #      protocol          = "tcp"
  #      from_port         = 5432
  #      to_port           = 5432
  #    },
  #    {
  #      primary_key       = "2"
  #      vpc_default_sg_id = "${module.networking.vpc_default_sg_id}"
  #      protocol          = "tcp"
  #      from_port         = 5000
  #      to_port           = 5000
  #    },
  #  ]
  #
  type = list(object({
    primary_key        = string
    vpc_default_sg_id  = string
    protocol           = string
    from_port          = number
    to_port            = number
  }))
  default = []
  description = "If passed, this adds ingress rules to the VPC's default security group with ECS's security group as a source"
}

variable "use_ecr" {
  type        = bool
  default     = true
  description = "If enabled, ECR read permissions are added to the role"
}

variable "use_adot_as_sidecar" {
  type        = bool
  default     = false
  description = "If enabled, add ADOT task definition to existing task definitions"
}

variable "ecr_repository_name" {}
variable "image" {}

variable "load_balancer" {
  type        = bool
  default     = false
  description = "Attach to a pre-existing load balancer?"
}

variable "lb_type" {
  type        = string
  default     = "application"
  description = "Select either application or network load balancer type to ensure proper security group setup"
}

variable "lb_target_group_arn" {}
variable "lb_security_group_id" {}
variable "lb_container_port" {}
