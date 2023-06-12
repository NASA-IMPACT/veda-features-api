output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.db.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.db.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.db.username
}

output "protocol_on_aws_alb_listener" {
  description = "HTTP/HTTPS protocol on the ALB Listener"
  value       = aws_alb_listener.alb_listener_ecs.protocol
}

output "alb_url" {
  value = "http://${aws_alb.alb_ecs.dns_name}"
}
