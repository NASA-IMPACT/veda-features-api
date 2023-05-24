module "networking" {
  source               = "github.com/developmentseed/tf-seed/modules/networking"
  project_name         = var.project_name
  env                  = "${var.env}"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${var.availability_zones}"
  tags                 = "${var.tags}"
}

resource "aws_security_group_rule" "ecs_service_port_addon" {
  description = "opened for ECS service port"
  type        = "ingress"
  from_port   = var.service_port
  to_port     = var.service_port
  protocol    = "tcp"
  security_group_id        = module.networking.default_sg_id
  source_security_group_id = module.networking.default_sg_id

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
  security_group_id        = module.networking.default_sg_id
  source_security_group_id = module.ecs_cluster.service_security_group_id

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}
