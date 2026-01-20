resource "aws_lb_target_group" "app" {
  name        = "${local.service_name}-tg"
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id

  # Fargate -> ip, EC2 -> instance
  target_type = local.is_fargate ? "ip" : "instance"

  health_check {
    enabled             = true
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    path                = var.health_check_path
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "http" {
  listener_arn = data.aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }
}
