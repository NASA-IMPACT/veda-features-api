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
  name                    = "veda-wfs3-db-config"
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
