output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "secrets_manager_arn" {
  value = aws_secretsmanager_secret.app_secrets.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}
output "app_secret_name" {
  description = "The name of the AWS Secrets Manager secret for the app"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
  description = "The URL of the ECR repository"
}