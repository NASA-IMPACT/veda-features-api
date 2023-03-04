resource "aws_alb_target_group" "alb_target_group" {
  name                 = "tf-${var.project_name}-target-group"
  port                 = var.service_port
  protocol             = "HTTP"
  vpc_id               = module.networking.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    interval            = 60
    path                = "/conformance"
    port                = 8080
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }

  depends_on = [
    aws_alb.alb_ecs
  ]
}

/* security group for ALB */
resource "aws_security_group" "web_inbound_sg" {
  name        = "tf-${var.project_name}-web-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = var.service_port
    to_port     = var.service_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-${var.project_name}-web-inbound-sg"
  }
}

resource "aws_alb" "alb_ecs" {
  name            = "tf-${var.project_name}-alb"
  subnets         = module.networking.public_subnets_id
  security_groups = concat(module.networking.security_groups_ids, [aws_security_group.web_inbound_sg.id])

  tags = merge({
    Name        = "tf-${var.project_name}-alb"
  }, var.tags)
}

resource "aws_alb_listener" "alb_listener_ecs" {
  load_balancer_arn = aws_alb.alb_ecs.arn
  port              = var.service_port
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.alb_target_group]

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}