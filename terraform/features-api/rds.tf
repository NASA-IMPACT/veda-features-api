resource "aws_db_subnet_group" "db" {
  name       = "tf-${var.project_name}-${var.env}-subnet-group"
  subnet_ids = data.aws_subnets.private.ids
  tags = {
    Name = "tf-${var.project_name}-subnet-group"
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "tf-${var.project_name}-${var.env}-postgres14-param-group"
  family = "postgres14"

  parameter {
    name = "work_mem"
    # NOTE: I had `work_mem` set to ~100MB and `max_connections` around 75 and TileJSON completely failed
    # 16MB
    value = var.env == "staging" ? "16384" : "8192"
  }

  parameter {
    name         = "max_connections"
    value        = "475"
    apply_method = "pending-reboot"
  }

  #  NOTE: here to show what shared_buffers are but doesn't really make sense why it won't provision with these
  #  parameter {
  #    name  = "shared_buffers"
  #    value = var.env == "staging" ? "8064856" : "4032428"
  #    apply_method = "pending-reboot"
  #  }

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
  db_name        = "veda"
  identifier     = "${var.project_name}-${var.env}"
  engine         = "postgres"
  engine_version = "14.3"
  // https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  allocated_storage           = 100
  max_allocated_storage       = 500
  storage_type                = "gp2"
  instance_class              = var.env == "staging" ? "db.r5.xlarge" : "db.r5.large"
  db_subnet_group_name        = aws_db_subnet_group.db.name
  skip_final_snapshot         = true
  apply_immediately           = true
  backup_retention_period     = 7
  vpc_security_group_ids      = [aws_security_group.default_sg.id]
  username                    = "postgres"
  password                    = random_password.master_password.result
  allow_major_version_upgrade = true
  parameter_group_name        = aws_db_parameter_group.default.name
}


