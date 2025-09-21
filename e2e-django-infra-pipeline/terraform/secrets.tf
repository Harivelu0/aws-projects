resource "random_string" "secret_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.project_name}-secrets-${random_string.secret_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    DB_NAME           = var.db_name
    DB_USER           = var.db_username
    DB_PASSWORD       = var.db_password
    DB_HOST           = aws_db_instance.mysql.endpoint
    DB_PORT           = "3306"
    DJANGO_SECRET_KEY = var.django_secret_key
    ADMIN_PASSWORD    = var.admin_password 
  })
}

resource "aws_ssm_parameter" "app_secret_name" {
  name        = "/${var.project_name}/app_secret_name"
  description = "Name of the secret in AWS Secrets Manager"
  type        = "String"
  value       = aws_secretsmanager_secret.app_secrets.name
}