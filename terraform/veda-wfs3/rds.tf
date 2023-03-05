resource "aws_db_subnet_group" "db" {
  name       = "tf-${var.project_name}-${var.env}-subnet-group"
  subnet_ids = module.networking.private_subnets_id
  tags = {
    Name = "tf-${var.project_name}-subnet-group"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "tf-${var.project_name}-${var.env}-postgres14-param-group"
  family = "postgres14"

  parameter {
    name  = "work_mem"
    value = "78125"
  }

  parameter {
    name  = "max_connections"
    value = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "seq_page_cost"
    value = "1"
  }

  parameter {
    name  = "random_page_cost"
    value = "1.2"
  }
}

resource "aws_db_instance" "db" {
  db_name                  = "veda"
  identifier               = "${var.project_name}-${var.env}"
  engine                   = "postgres"
  engine_version           = "14.3"
  // https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  allocated_storage        = 100
  max_allocated_storage    = 500
  storage_type             = "gp2"
  instance_class           = "db.r5.xlarge"
  db_subnet_group_name     = aws_db_subnet_group.db.name
  vpc_security_group_ids   = module.networking.security_groups_ids
  skip_final_snapshot      = true
  apply_immediately        = true
  backup_retention_period  = 7
  username                 = "postgres"
  password                 = var.db_password
  allow_major_version_upgrade = true
  parameter_group_name     = aws_db_parameter_group.default.name
}


