resource "aws_lb" "app_alb" {
  name = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public[*].id
  tags = {
    Namw="${var.project_name}-alb"
  
  }
}

resource "aws_lb_target_group" "app_tg" {
  name = "${var.project_name}-tg"
  port = 8000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path = "/"
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 3
    interval = 30
    timeout = 5
  }
  tags = {
    Name="${var.project_name}-tg"

  }
}

resource "aws_lb_listener" "http" {
load_balancer_arn=aws_lb.app_alb.arn
port = 80
protocol = "HTTP"
default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.app_tg.arn
}  
}
