# module "ecs-fargate-service" {
#   source              = "../../modules/ecs-fargate-service"
#   vpc_id              = var.vpc_id
#   application         = var.application
#   region              = var.region
#   ecs_cluster         = "${var.environment}-cluster"
#   lb_name             = "${var.environment}-alb-hello-client"
#   environment         = var.environment
#   container_version   = var.container_version
#   log_group_name      = "dev/hello-service"
#   ecr_repository_name = "public.ecr.aws/j9e2f6x4/hello-svc"
#   port                = 80
#   health_check_path   = "/hello"
#   cloudmap_namespace  =  var.cloudmap_namespace
#   cpu                 = "512"
#   memory              = "1024"
#   path_pattern        = "/hello"
# }


module "ecs-fargate-service" {
  source = "../../modules/ecs-fargate-service"

  vpc_id             = var.vpc_id
  application        = var.application
  region             = var.region
  ecs_cluster        = "${var.environment}-cluster"
  lb_name            = "${var.environment}-alb-hello-client"
  environment        = var.environment
  container_version  = var.container_version
  cloudmap_namespace = var.cloudmap_namespace

  # ✅ NEW: choose runtime
  compute_type = var.compute_type

  # ✅ NEW: EC2 capacity (used only when compute_type=EC2)
  ecs_instance_min     = var.ecs_instance_min
  ecs_instance_max     = var.ecs_instance_max
  ecs_instance_desired = var.ecs_instance_desired

  # ✅ NEW: task autoscaling (both)
  ecs_tasks_min                   = var.ecs_tasks_min
  ecs_tasks_max                   = var.ecs_tasks_max
  alb_req_per_target_target_value = var.alb_req_per_target_target_value
  scale_in_cooldown               = var.scale_in_cooldown
  scale_out_cooldown              = var.scale_out_cooldown

  # your service-specific values (keep as-is)
  log_group_name      = "dev/hello-service"
  ecr_repository_name = "public.ecr.aws/j9e2f6x4/hello-svc"
  port                = 80
  health_check_path   = "/hello"
  path_pattern        = "/hello"

  # IMPORTANT: cpu/memory should be numbers (not strings)
  cpu    = 512
  memory = 1024
}
