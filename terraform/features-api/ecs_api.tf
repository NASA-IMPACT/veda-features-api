data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    "Scope" = "private"
  }
}

module "ecs_cluster" {
  source      = "../modules/aws_ecs_service"
  environment = var.env
  region      = var.region
  vpc_id      = var.vpc_id
  subnet_ids  = data.aws_subnets.private.ids

  service_name       = "${var.project_name}-service"
  service_port       = var.service_port
  service_protocol   = "tcp"
  cpu                = 2048
  memory             = 4096
  instance_count     = 1
  log_retention_days = 60

  container_command           = ["/bin/bash", "startup.sh"]
  container_working_directory = "/tmp/"

  container_secrets = [
    {
      name      = "AWS_CONFIG"
      valueFrom = aws_secretsmanager_secret.config.arn
    },
    {
      name      = "DB_CONFIG"
      valueFrom = aws_secretsmanager_secret.db_config.arn
    },
  ]

  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = var.env
    },
    {
      name  = "IS_ECS"
      value = "True"
    },
    {
      name  = "OTEL_PROPAGATORS"
      value = "xray"
    },
    {
      name  = "OTEL_PYTHON_ID_GENERATOR"
      value = "xray"
    },
    {
      name  = "OTEL_RESOURCE_ATTRIBUTES"
      value = "service.name=veda-wfs3-${var.env}"
    },
    {
      name  = "OTEL_RESOURCE_ATTRIBUTES"
      value = "service.name=veda-wfs3-${var.env}"
    },
    {
      name  = "OTEL_TRACES_SAMPLER"
      value = "traceidratio"
    },
    {
      name  = "OTEL_TRACES_SAMPLER_ARG"
      value = "0.5"
    },
    {
      name  = "FORWARDED_ALLOW_IPS"
      value = "*"
    },
    {
      // stupid hack b/c of FastAPI and Starlette bug
      name  = "FAST_API_SCHEME"
      value = "http" //quick hack for now, TODO: include 'contains' function
    }
  ]

  container_ingress_cidrs  = ["0.0.0.0/0"]
  container_ingress_sg_ids = []

  use_adot_as_sidecar = false
  use_ecr             = true
  ecr_repository_name = module.ecr_registry_wfs.registry_name
  ecr_repository_arn  = module.ecr_registry_wfs.registry_arn
  image               = "${module.ecr_registry_wfs.repository_url}:latest"

  load_balancer        = true
  lb_type              = "application"
  lb_target_group_arn  = aws_alb_target_group.alb_target_group.arn
  lb_security_group_id = aws_security_group.web_inbound_sg.id
  lb_container_port    = var.service_port

  tags = var.tags
}

##############################################################
# The ECS task execution role represented by the output
# `module.ecs_cluster.ecs_execution_role_id`
# requires additional policies depending on what it needs
# to access in AWS. Hence the attachments below
##############################################################

##############################################################
# give acess to AWS secret manager to access
# `container_secrets` pumped into the task above
#
data "aws_iam_policy_document" "api_ecs_execution_attachment" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
    ]

    resources = [
      aws_secretsmanager_secret.config.arn,
      aws_secretsmanager_secret.db_config.arn
    ]
  }
}

resource "aws_iam_role_policy" "api_ecs_execution_role_policy" {
  name   = "${var.project_name}-api-access-secret-manager"
  role   = module.ecs_cluster.ecs_execution_role_id
  policy = data.aws_iam_policy_document.api_ecs_execution_attachment.json
}
