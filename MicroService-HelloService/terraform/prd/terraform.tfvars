environment        = "prod"
vpc_id             = "vpc-0b6ca0870d2fff073"
cloudmap_namespace = "corp"
container_version  = "v1"

desired_count = 1

# EC2 instances for ECS cluster capacity
ecs_instance_min     = 1
ecs_instance_max     = 5
ecs_instance_desired = 1

# task autoscaling
ecs_tasks_min                   = 1
ecs_tasks_max                   = 10
alb_req_per_target_target_value = 1500
scale_in_cooldown               = 300
scale_out_cooldown              = 60
