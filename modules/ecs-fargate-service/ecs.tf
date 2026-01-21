# resource "aws_ecs_task_definition" "app_task" {
#   family = "${var.application}-${var.environment}"

#   container_definitions = jsonencode([
#     {
#       name      = "${var.application}-${var.environment}"
#       image     = "${var.ecr_repository_name}:${var.container_version}"
#       essential = true

#       portMappings = [
#         {
#           containerPort = var.port
#           hostPort      = 0
#           protocol      = "tcp"
#         }
#       ]

#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.log.name
#           awslogs-region        = data.aws_region.current.id
#           awslogs-stream-prefix = var.container_version
#         }
#       }

#       memory = var.memory
#       cpu    = var.cpu
#     }
#   ])

#   requires_compatibilities = ["EC2"]
#   network_mode             = "bridge"

#   execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
#   task_role_arn      = aws_iam_role.ecsTaskExecutionRole.arn
# }

resource "aws_ecs_task_definition" "app_task" {
  family       = "hello-dev"
  network_mode = "bridge" # You can use 'bridge' or 'host' but not both with hostPort
  container_definitions = jsonencode(
    [
      {
        name      = "hello-dev"
        image     = "public.ecr.aws/j9e2f6x4/hello-svc:v1"
        memory    = 1024
        cpu       = 512
        essential = true

        portMappings = [
          {
            containerPort = 80 # Only containerPort, no hostPort
            protocol      = "tcp"
          },
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "dev/hello-service"
            awslogs-region        = "ap-south-1"
            awslogs-stream-prefix = "v1"
          }
        }
      },
    ]
  )

  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  requires_compatibilities = ["EC2"]
}


# resource "aws_ecs_service" "app_service" {
#   name            = "${var.application}-${var.environment}"
#   cluster         = data.aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.app_task.arn

#   desired_count         = var.desired_count
#   wait_for_steady_state = false
#   scheduling_strategy   = "REPLICA"
#   force_new_deployment  = true

#   # Use EC2 capacity provider (recommended)
#   capacity_provider_strategy {
#     capacity_provider = aws_ecs_capacity_provider.ec2.name
#     weight            = 1
#     base              = 1
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   # If your app takes time to boot, increase this
#   health_check_grace_period_seconds = 120

#   load_balancer {
#     target_group_arn = aws_lb_target_group.app.arn
#     container_name   = "${var.application}-${var.environment}"
#     container_port   = var.port
#   }

#   # For bridge mode, specify port for Cloud Map
#   service_registries {
#     registry_arn = aws_service_discovery_service.sd.arn
#     port         = var.port
#   }

#   timeouts {
#     create = "20m"
#     update = "20m"
#   }

#   depends_on = [
#     aws_ecs_cluster_capacity_providers.this
#   ]
# }

resource "aws_ecs_service" "app_service" {
  name                              = "hello-dev"
  cluster                           = "arn:aws:ecs:ap-south-1:***:cluster/dev-cluster"
  task_definition                   = aws_ecs_task_definition.app_task.arn
  desired_count                     = 1
  launch_type                       = "EC2" # Ensure this is EC2 if you're using EC2 instances
  platform_version                  = "LATEST"
  scheduling_strategy               = "REPLICA"
  force_new_deployment              = true
  health_check_grace_period_seconds = 120

  # Load balancer configuration
  load_balancer {
    container_name   = "hello-dev"
    container_port   = 80 # Use containerPort instead of hostPort
    target_group_arn = aws_lb_target_group.app.arn
  }

  timeouts {
    create = "20m"
    update = "20m"
  }
}



# -----------------------------
# ECS service autoscaling (tasks)
# -----------------------------
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.app_service.name}"

  min_capacity = var.ecs_tasks_min
  max_capacity = var.ecs_tasks_max
}

resource "aws_appautoscaling_policy" "ecs_alb_rps" {
  name               = "${var.application}-${var.environment}-alb-rps"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs.resource_id

  target_tracking_scaling_policy_configuration {
    target_value = var.alb_req_per_target_target_value

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${data.aws_lb.alb.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
    }

    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}
