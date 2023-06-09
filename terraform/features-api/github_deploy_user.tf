# resource "aws_iam_user" "deploy_user" {
#   name = "${var.project_name}-${var.env}-deploy-user"
#   path = "/"
#   tags = var.tags
# }

# // NOTE: we need to have extra policies added to our
# // deploy user for Github AWS Actions to work
# resource "aws_iam_user_policy" "deploy" {
#   name   = "${var.registry_name}_deploy_extended"
#   user   = aws_iam_user.deploy_user.name
#   policy = data.aws_iam_policy_document.extended_deploy.json
# }

# data "aws_iam_policy_document" "extended_deploy" {
#   statement {
#     actions = [
#       "iam:PassRole",
#       "ecr:InitiateLayerUpload",
#       "ecs:RegisterTaskDefinition",
#       "ecs:DescribeServices",
#       "ecs:UpdateService",
#     ]

#     resources = [
#       module.ecr_registry_wfs.registry_arn,
#       module.ecs_cluster.service_cluster_arn,
#       module.ecs_cluster.service_arn,
#       module.ecs_cluster.ecs_execution_role_arn,
#     ]
#   }
# }