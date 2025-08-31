# execution role - pull image, push logs
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
      Action = ["sts:AssumeRole"]
    }]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
            Effect="Allow",
            Principal={
                Service=["ecs-tasks.amazonaws.com"]
            },
            Action=["sts:AssumeRole"]
        }]
  })
}

resource "aws_iam_policy" "secrets_read" {
  name = "${var.project_name}-secrets-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"]
      Resource=aws_secretsmanager_secret.djsecret.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_read_attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_read.arn
}