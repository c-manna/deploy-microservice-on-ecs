environment        = "dev"
vpc_id             = "vpc-0b6ca0870d2fff073"
cloudmap_namespace = "corp"
container_version  = "v1"

compute_type = "FARGATE"

desired_count = 1

# task autoscaling
ecs_tasks_min                   = 1
ecs_tasks_max                   = 5
alb_req_per_target_target_value = 500
scale_in_cooldown               = 120
scale_out_cooldown              = 30
