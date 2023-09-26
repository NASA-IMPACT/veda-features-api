########################################################################
# Key for secrets
########################################################################
data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}


########################################################################
# Secrets
########################################################################
resource "random_id" "sm_suffix" {
  byte_length = 2
}

resource "aws_secretsmanager_secret" "config" {
  name                    = "aws-config-${random_id.sm_suffix.hex}"
  kms_key_id              = data.aws_kms_key.secretsmanager.id
  tags                    = var.tags
}

resource "aws_secretsmanager_secret" "db_config" {
  name                    = "${var.project_name}-${var.env}-db-config"
  kms_key_id              = data.aws_kms_key.secretsmanager.id
  tags                    = var.tags
}

########################################################################
# Key/Value default to prevent task definitions from stopping at runtime
########################################################################
resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.config.id
  secret_string = jsonencode(var.default_secret)
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db_config.id
  secret_string = jsonencode({
    username    = aws_db_instance.db.username,
    password    = random_password.master_password.result,
    host        = aws_db_instance.db.address,
    port        = aws_db_instance.db.port,
    dbname      = aws_db_instance.db.db_name,
    engine      = aws_db_instance.db.engine,
    vpc_id      = data.aws_vpc.vpc.id
  })
}