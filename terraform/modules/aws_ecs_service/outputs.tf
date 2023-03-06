output "ecs_execution_role_id" {
  value = aws_iam_role.ecs_execution_role.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "service_security_group_id" {
  value = aws_security_group.service.id
}

output "service_cluster_id" {
  value = aws_ecs_cluster.service.id
}

output "service_cluster_name" {
  # NOTE: the cluster name should be the same
  # as the service name and taskdef name
  # so no reason to export them separately
  value = aws_ecs_cluster.service.name
}

output "service_cluster_arn" {
  value = aws_ecs_cluster.service.arn
}

output "service_id" {
  value = aws_ecs_service.service.id
}

output "service_arn" {
  # An extra convenience, because the id and arn are the same
  value = aws_ecs_service.service.id
}

output "service_task_definition_arn" {
  value = aws_ecs_task_definition.service.arn
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.service.arn
}
