variable "environment" {}
variable "registry_name" {}
variable "enable_registry_scanning" {
  type        = bool
  default     = true
  description = "Enable scanning containers for common vulnerabilities"
}
variable "mutable_image_tags" {
  type    = bool
  default = false
}

variable "enable_deploy_user" {
  type    = bool
  default = true
}

variable "iam_deploy_username" {}

variable "tags" {
  type    = map
  default = {}
}
