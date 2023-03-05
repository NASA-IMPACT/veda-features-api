########################################################################
# Data Bits
########################################################################
data "aws_ecr_repository" "service" {
  count = var.use_ecr ? 1 : 0
  name  = var.ecr_repository_name
}


########################################################################
# IAM
########################################################################
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.service_name}-${var.environment}_ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecs_execution_attachment" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.service_name}-${var.environment}_ecs_execution_role_policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.ecs_execution_attachment.json
}

data "aws_iam_policy_document" "ecs_ecr_access_attachment" {
  count = var.use_ecr ? 1 : 0

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]

    resources = [
      data.aws_ecr_repository.service[0].arn,
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_ecr_access_role_policy" {
  count  = var.use_ecr ? 1 : 0
  name   = "${var.service_name}-${var.environment}_ecs_ecr_access_role_policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.ecs_ecr_access_attachment[0].json
}


########################################################################
# Security Groups
########################################################################
resource "aws_security_group" "service" {
  name        = "tf-${var.service_name}-${var.environment}"
  description = "${var.service_name}-${var.environment} security group"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "tf-${var.service_name}-${var.environment}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "service_egress" {
  security_group_id = aws_security_group.service.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

// bind the ECS service's SG as a source
// to the VPC's default SG if it was passed as a variable
resource "aws_security_group_rule" "rds_sg_allows_ecs_sg" {
  for_each   = {
    for index, rule in var.additional_sg_ingress_rules_for_vpc_default_sg:
    rule.primary_key => rule # this works b/c one key has to be primary
  }
  security_group_id = each.value.vpc_default_sg_id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  source_security_group_id = aws_security_group.service.id
}

resource "aws_security_group_rule" "service_ingress_cidrs" {
  count             = length(var.container_ingress_cidrs) > 0 ? 1 : 0
  security_group_id = aws_security_group.service.id
  type              = "ingress"
  from_port         = var.service_port
  to_port           = var.service_port
  protocol          = var.service_protocol
  cidr_blocks       = var.container_ingress_cidrs
}

// TODO: we  can't use IDs here as keys in for_each b/c they aren't existing at apply time
// so we have to figure out how to use `depends_on` with this next statement
// https://discuss.hashicorp.com/t/for-each-value-depends-on-resource-attributes-that-cannot-be-determined-until-apply/6061/2
resource "aws_security_group_rule" "service_ingress_sgs" {
  for_each                 = var.container_ingress_sg_ids
  security_group_id        = aws_security_group.service.id
  type                     = "ingress"
  from_port                = var.service_port
  to_port                  = var.service_port
  protocol                 = var.service_protocol
  source_security_group_id = each.value
}

resource "aws_security_group_rule" "service_ingress_lb" {
  count                    = var.load_balancer && var.lb_type == "application" ? 1 : 0
  security_group_id        = aws_security_group.service.id
  type                     = "ingress"
  from_port                = var.service_port
  to_port                  = var.service_port
  protocol                 = var.service_protocol
  source_security_group_id = var.lb_security_group_id
}


########################################################################
# ECS
########################################################################
resource "aws_ecs_cluster" "service" {
  name = "tf-${var.service_name}-${var.environment}"
  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name                    = "tf-${var.service_name}-${var.environment}"
  cluster                 = aws_ecs_cluster.service.id
  task_definition         = aws_ecs_task_definition.service.arn
  desired_count           = var.instance_count
  launch_type             = "FARGATE"
  propagate_tags          = "SERVICE"
  enable_ecs_managed_tags = true
  enable_execute_command  = true
  tags                    = var.tags

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.service.id]
    //assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer ? [var.lb_target_group_arn] : []
    content {
      target_group_arn = var.lb_target_group_arn
      container_name   = "tf-${var.service_name}-${var.environment}"
      container_port   = var.lb_container_port
    }
  }
}

data "template_file" "container_definition" {
  // NOTE: the container definition `name` has to be the same as the service 
  // for the load balancer to attach and discover correctly even though 
  // this ticket says it should work otherwise :shrug:
  // https://github.com/hashicorp/terraform/issues/2888
  template = file("${path.module}/container_definition.json")

  vars = {
    service_name          = var.service_name
    environment           = var.environment
    image                 = var.image
    container_command     = length(var.container_command) > 0 ? jsonencode(var.container_command) : ""
    working_directory     = var.container_working_directory
    container_secrets     = jsonencode(var.container_secrets)
    container_environment = jsonencode(var.container_environment)
    service_protocol      = var.service_protocol
    service_port          = var.service_port
    use_adot_as_sidecar   = var.use_adot_as_sidecar ? "on" : ""
    log_group             = aws_cloudwatch_log_group.service.name
    region                = var.region
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "tf-${var.service_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = var.tags
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  container_definitions    = data.template_file.container_definition.rendered
}

#######################################################################
# AWS Distro Open Telemetry (ADOT) Permissions
#######################################################################
# give access for AWS OTEL for observability
# https:aws-otel.github.io/docs/setup/ecs
# note that all the logging policies were already attached above
data "aws_iam_policy_document" "api_ecs_to_otel_access" {
  statement {
    actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets",
        "xray:GetSamplingStatisticSummaries",
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "ssm:GetParameters"
    ]

    resources = [
       "*",
    ]
  }
}

resource "aws_iam_role_policy" "api_ecs_execution_role_policy_attach_otel" {
  name   = "${var.service_name}-${var.environment}-api-access-otel"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.aws_iam_policy_document.api_ecs_to_otel_access.json
}

########################################################################
# LOGGING
########################################################################
resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/tf-${var.service_name}-${var.environment}-log-group"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}
