#####################################################
# Execution Role
#####################################################
resource "aws_iam_role" "lambda_exec_role" {
  provider = aws.west2
  name = "lambda-exec-role-s3-event-bridge-${var.project_name}-${var.env}"
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

###############################
# Logging
###############################
resource "aws_iam_policy" "lambda_logging" {
  provider = aws.west2
  name        = "lambda-logging-${var.project_name}-${var.env}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.group.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  provider = aws.west2
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

###############################
# SFN StartExecution Policy
###############################
resource "aws_iam_policy" "lambda_sfn_start_exec" {
  provider = aws.west2
  name        = "lambda-startexec-on-sfn-${var.project_name}-${var.env}"
  path        = "/"
  description = "IAM policy for allowing lambda to start execution on SFN"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "states:StartExecution"
      ],
      "Resource": "arn:aws:states:us-west-1:853558080719:stateMachine:veda-data-pipelines-dev-vector-stepfunction-discover",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sfn_start_exec" {
  provider = aws.west2
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sfn_start_exec.arn
}

#####################################################
# Lambda
#####################################################
data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "functions/s3_event_bridge_to_sfn_execute"
  output_path = "s3_event_bridge_to_sfn_execute.zip"
}

resource "aws_lambda_function" "lambda" {
  provider = aws.west2
  filename         = "s3_event_bridge_to_sfn_execute.zip"
  function_name    = "s3-event-bridge-to-sfn-execute-${var.project_name}-${var.env}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.archive.output_base64sha256
  runtime          = "python3.7"
  publish          = true
  tags             = var.tags
}

resource "aws_cloudwatch_log_group" "group" {
  provider = aws.west2
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 5
  tags              = var.tags
}

#####################################################
# RESOURCE POLICY for EVENT INVOCATION
#####################################################
resource "aws_lambda_permission" "s3_invoke" {
  provider = aws.west2
  action           = "lambda:InvokeFunction"
  function_name    = aws_lambda_function.lambda.function_name
  principal        = "s3.amazonaws.com"
  statement_id     = "AllowInvocationFromS3Bucket-${var.project_name}-${var.env}"
  source_account   = "114506680961"
  source_arn       = "arn:aws:s3:::veda-data-store-staging"
}

output "s3_event_bridge_lambda_arn" {
  value = "${aws_lambda_function.lambda.arn}:${aws_lambda_function.lambda.version}"
}
