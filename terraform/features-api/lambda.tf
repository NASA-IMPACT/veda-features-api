resource "aws_lambda_invocation" "db_init" {
  function_name = aws_lambda_function.lambda_init_db.function_name

  input = jsonencode({
    "user_params" : {
      "username" : "username"
      "password" : "password"
      "dbname" : "ghgc"
    }
  })

  triggers = {
    folder_path = sha1(join("", [for f in fileset("../../db", "*") : filesha1("../../db/${f}")]))
  }

  # triggers = {
  #   handler_file_path = filemd5("../../db/handler.py")
  #   docker_file_path  = filemd5("../../db/Dockerfile")
  # }

  lifecycle_scope = "CRUD"
  qualifier       = "$LATEST"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "lambda_policy" {
  statement {

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "ecr:SetRepositoryPolicy",
      "ecr:GetRepositoryPolicy"
    ]

    resources = [
      aws_secretsmanager_secret.config.arn,
      aws_secretsmanager_secret.db_config.arn,
      module.ecr_registry_wfs.registry_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }


  # statement {
  #   effect = "Allow"

  #   actions = [
  #     "logs:CreateLogStream",
  #     "logs:PutLogEvents"
  #   ]

  #   resources = [aws_cloudwatch_log_group.example.arn]
  # }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.project_name}-${var.env}-lambda-initdb-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  name   = "${var.project_name}-${var.env}-api-access-secret-manager-lambda"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  name              = "/aws/lambda/${var.project_name}-${var.env}-initdb-function"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda_init_db" {
  code_signing_config_arn = ""
  description             = "Lambda function to init medium DB"
  image_uri               = "${module.ecr_registry_db.repository_url}:latest"
  function_name           = "${var.project_name}-${var.env}-initdb-function"
  role                    = aws_iam_role.iam_for_lambda.arn
  package_type            = "Image"

  image_config {
    command = ["handler.handler"]
  }

  depends_on = [
    aws_iam_role_policy.lambda_execution_role_policy,
    aws_cloudwatch_log_group.lambda_cloudwatch_group,
    aws_db_instance.db
  ]

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda-db-init.id]
  }
  environment {
    variables = {
      CONN_SECRET_ARN = aws_secretsmanager_secret.db_config.arn
    }
  }
}

