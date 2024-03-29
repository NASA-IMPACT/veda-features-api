
/* security group for ALB */
resource "aws_security_group" "web_inbound_sg" {
  name        = "tf-${var.project_name}-${var.env}-web-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "tf-${var.project_name}-${var.env}-web-inbound-sg"
  }
}

resource "aws_security_group" "https_web_inbound_sg" {
  name        = "tf-${var.project_name}-${var.env}-https-web-inbound-sg"
  description = "Allow HTTPS from Anywhere into ALB"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 8
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
    Name = "tf-${var.project_name}-${var.env}-https-web-inbound-sg"
  }
}

resource "aws_alb" "alb_ecs" {
  name            = "tf-${var.project_name}-${var.env}-alb"
  subnets         = module.networking.public_subnets_id
  security_groups = concat(module.networking.security_groups_ids, [aws_security_group.https_web_inbound_sg.id])

  tags = merge({
    Name        = "tf-${var.project_name}-alb"
  }, var.tags)
}

resource "aws_alb_target_group" "alb_target_group" {
  name                 = "tf-${var.project_name}-${var.env}-tgp"
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
    path                = "/healthz"
    port                = var.service_port
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

#resource "aws_alb_listener" "alb_listener_ecs" {
#  load_balancer_arn = aws_alb.alb_ecs.arn
#  port              = 80
#  protocol          = var.alb_protocol
#  depends_on        = [aws_alb_target_group.alb_target_group]
#
#  default_action {
#    target_group_arn = aws_alb_target_group.alb_target_group.arn
#    type             = "forward"
#  }
#}

resource "aws_alb_listener" "alb_listener_ecs" {
  load_balancer_arn = aws_alb.alb_ecs.arn
  port              = 443
  protocol          = var.alb_protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn
  depends_on        = [aws_alb_target_group.alb_target_group]

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}