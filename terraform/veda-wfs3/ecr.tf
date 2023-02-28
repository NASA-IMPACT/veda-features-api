module "ecr_registry" {
  source = "../modules/aws_ecr"
  environment              = var.env
  registry_name            = var.registry_name
  enable_registry_scanning = true
  mutable_image_tags       = true
  enable_deploy_user       = true
  iam_deploy_username      = aws_iam_user.deploy_user.name
  tags = var.tags
}