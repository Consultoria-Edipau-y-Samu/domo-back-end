resource "aws_secretsmanager_secret" "aurora_secret" {
  name = "aurora-credentials"
  description = "Aurora DB credentials for Lambda"
}

resource "aws_secretsmanager_secret_version" "aurora_secret_value" {
  secret_id     = aws_secretsmanager_secret.aurora_secret.id
  secret_string = jsonencode({
    host     = var.db_host
    username = var.db_username
    password = var.db_password
    database = var.db_name
  })
}
