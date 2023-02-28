output "registry_arn" {
  value = aws_ecr_repository.service.arn
}

output "registry_name" {
  value = aws_ecr_repository.service.name
}

output "repository_url" {
  value = aws_ecr_repository.service.repository_url
}
