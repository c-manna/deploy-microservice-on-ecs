resource "aws_ecs_task_definition" "task" {
  family = local.service_name

  # Fargate uses awsvpc; EC2 uses bridge (simple & standard)
  network_mode = local.is_fargate ? "awsvpc" : "bridge"

  requires_compatibilities = local.is_fargate ? ["FARGATE"] : ["EC2"]
  cpu                      = local.is_fargate ? tostring(var.cpu) : null
  memory                   = local.is_fargate ? tostring(var.memory) : null

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.service_name
      image     = "${var.ecr_repository_name}:${var.container_version}"
      essential = true

      portMappings = [
        local.is_fargate
        ? { containerPort = var.port, hostPort = var.port, protocol = "tcp" }
        : { containerPort = var.port, hostPort = 0, protocol = "tcp" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = var.container_version
        }
      }

      memory = var.memory
      cpu    = var.cpu
    }
  ])
}

resource "aws_ecs_service" "svc" {
  name            = local.service_name
  cluster         = data.aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn

  desired_count         = var.desired_count
  wait_for_steady_state = false
  force_new_deployment  = true
  scheduling_strategy   = "REPLICA"

  # For EC2 mode, use capacity provider strategy
  dynamic "capacity_provider_strategy" {
    for_each = local.is_ec2 ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.ec2[0].name
      weight            = 1
      base              = 1
    }
  }

  # For Fargate mode, use launch_type
  launch_type = local.is_fargate ? "FARGATE" : null

  # Only Fargate needs network_configuration (awsvpc)
  dynamic "network_configuration" {
    for_each = local.is_fargate ? [1] : []
    content {
      subnets          = data.aws_subnets.public.ids
      assign_public_ip = true
      security_groups  = [aws_security_group.task_sg[0].id]
    }
  }

  health_check_grace_period_seconds = 120

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.service_name
    container_port   = var.port
  }

  # Cloud Map service discovery
  service_registries {
    registry_arn = aws_service_discovery_service.sd.arn
    # For EC2 bridge mode Cloud Map needs port
    port = var.port
  }

  timeouts {
    create = "20m"
    update = "20m"
  }

  # Always reference this, but avoid the conditional list issue
  depends_on = local.is_ec2 ? [aws_ecs_cluster_capacity_providers.attach] : []
}

