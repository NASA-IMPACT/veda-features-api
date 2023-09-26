data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_subnets" "private_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.vpc.id}"]
  }

  tags = {
    "${tolist(keys(var.private_subnet_tag))[0]}" = "${tolist(values(var.private_subnet_tag))[0]}"
  }
}

data "aws_subnets" "public_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.vpc.id}"]
  }

  tags = {
    "${tolist(keys(var.public_subnet_tag))[0]}" = "${tolist(values(var.public_subnet_tag))[0]}"
  }
}

resource "aws_security_group_rule" "ecs_service_port_addon" {
  description = "opened for ECS service port"
  type        = "ingress"
  from_port   = var.service_port
  to_port     = var.service_port
  protocol    = "tcp"
  security_group_id        = "${data.aws_security_group.default.id}"
  source_security_group_id = "${data.aws_security_group.default.id}"

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_addon" {
  description = "Allow ESC to talk to RDS"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_group_id        = "${data.aws_security_group.default.id}"
  source_security_group_id = "${module.ecs_cluster.service_security_group_id}"

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}
