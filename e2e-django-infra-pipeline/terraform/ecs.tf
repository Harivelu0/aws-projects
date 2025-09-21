resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 14
}

# Task Definitions
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "django-app"
      image        = var.docker_image
      essential    = true
      portMappings = [{ containerPort = 8000, hostPort = 8000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [] # keep non-sensitive envs here if needed
      secrets = [
        # Use JSON key references for individual keys inside the secret
        { name = "DJANGO_SECRET_KEY", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DJANGO_SECRET_KEY::" },
        { name = "DB_NAME", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DB_NAME::" },
        { name = "DB_USER", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DB_USER::" },
        { name = "DB_PASSWORD", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DB_PASSWORD::" },
        { name = "DB_HOST", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DB_HOST::" },
        { name = "DB_PORT", valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:DB_PORT::" }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "django-app"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}
