resource "aws_secretsmanager_secret" "djsecret" {
  name = "${var.project_name}-secret"
  
}

resource "aws_secretsmanager_secret_version" "djsecretversion" {
    secret_id = aws_secretsmanager_secret.djsecret.id
    secret_string = jsonencode({
        DB_NAME = var.db.name
        DB_USER = var.db.username
        DB_PASSWORD = var.db.password
        DB_HOST = aws_db_instance.mysql_db.endpoint
        DB_PORT="3306"
        DJANGO_SECRET_KEY = var.djanko_secret_key
    })
  
}

