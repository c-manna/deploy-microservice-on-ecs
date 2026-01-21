resource "aws_lb_target_group" "app" {
  name        = "${var.application}-${var.environment}-tg"
  port        = var.port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = var.interval
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.timeout
    unhealthy_threshold = var.unhealthy_threshold
    path                = var.health_check_path
  }

  load_balancing_algorithm_type = "round_robin"
  slow_start                    = 120

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "http" {
  listener_arn = data.aws_lb_listener.listner.arn

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
