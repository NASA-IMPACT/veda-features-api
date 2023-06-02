resource "aws_security_group" "default_sg" {
  name   = "$${var.project_name}-${var.env}-default-sg"
  vpc_id = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "ecs_service_port_addon" {
  description              = "opened for ECS service port"
  type                     = "ingress"
  from_port                = var.service_port
  to_port                  = var.service_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default_sg.id
  source_security_group_id = aws_security_group.default_sg.id

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_addon" {
  description              = "Allow ESC to talk to RDS"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default_sg.id
  source_security_group_id = module.ecs_cluster.service_security_group_id

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}
