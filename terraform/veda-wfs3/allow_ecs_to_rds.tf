// Need an additional security group mapping to allow
// ECS to talk to DB
resource "aws_security_group_rule" "rds_sg_allows_ecs_sg" {
  description       = "Allow ESC to talk to RDS"
  security_group_id = module.networking.default_sg_id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id =  module.ecs_cluster.service_security_group_id
  depends_on = [
    module.networking,
    module.ecs_cluster
  ]

}