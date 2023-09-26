#module "ecr_registry" {
#  source = "github.com/developmentseed/tf-seed/modules/aws_ecr"
#  environment              = var.env
#  registry_name            = var.registry_name
#  enable_registry_scanning = true
#  mutable_image_tags       = true
#  enable_deploy_user       = true
#  iam_deploy_username      = aws_iam_user.deploy_user.name
#  tags = var.tags
#}

resource "aws_iam_user_policy" "default_deploy_user" {
  name   = "${var.registry_name}-${var.env}-deploy-policy"
  user   = aws_iam_user.deploy_user.name
  policy = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "sts:GetServiceBearerToken",
      "ecr-public:*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      aws_ecr_repository.service.arn
    ]
  }
}

resource "aws_ecr_repository" "service" {
  name = "tf-${var.registry_name}-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = var.tags
}

resource "null_resource" "build_ecr_image_wfs" {
  triggers = {
    folder_path = sha1(join("", [for f in fileset("../../veda-wfs3-app", "*") : filesha1("../../veda-wfs3-app/${f}")]))
  }

  provisioner "local-exec" {
    command = <<EOF
          cd ../../veda-wfs3-app
          aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.service.repository_url}
          docker build -t ${aws_ecr_repository.service.repository_url}:latest .
          docker push ${aws_ecr_repository.service.repository_url}:latest
          cd -
       EOF
  }
}