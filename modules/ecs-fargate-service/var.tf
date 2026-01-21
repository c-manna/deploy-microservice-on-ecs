variable "service_name" { default = "" }

variable "vpc_id" {
  default = "vpc-0b6ca0870d2fff073"
}

variable "lb_name" { default = "dev-alb-hello-client" }

variable "ecs_cluster" { default = "dev-cluster" }

variable "region" { default = "ap-south-1" }

variable "desired_count" {
  type    = number
  default = 1
}

variable "application" { default = "" }
variable "environment" { default = "" }

variable "container_version" { default = "" }
variable "ecr_repository_name" { default = "" }

variable "log_group_name" { default = "" }

variable "port" {
  type    = number
  default = 80
}

variable "health_check_path" { default = "/" }

variable "cloudmap_namespace" { default = "corp" }

variable "path_pattern" { default = "/*" }

variable "interval" {
  type    = number
  default = 50
}

variable "timeout" {
  type    = number
  default = 25
}

variable "unhealthy_threshold" {
  type    = number
  default = 5
}

variable "memory" {
  type    = number
  default = 512
}

variable "cpu" {
  type    = number
  default = 256
}

# -----------------------------
# EC2 capacity (NEW)
# -----------------------------
variable "ecs_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ecs_instance_min" {
  type    = number
  default = 1
}

variable "ecs_instance_max" {
  type    = number
  default = 3
}

variable "ecs_instance_desired" {
  type    = number
  default = 1
}

# Use private subnets by default. If you want to force subnets, pass them.
variable "ecs_instance_subnet_ids" {
  type    = list(string)
  default = []
}

# If you want public instances (not recommended), set true + use public subnet IDs
variable "ecs_instances_public_ip" {
  type    = bool
  default = false
}

# Optional SSH key
variable "ecs_key_name" {
  type    = string
  default = null
}

# EC2 instance scaling with capacity provider
variable "capacity_provider_target_capacity" {
  type    = number
  default = 80
}

# ECS Service autoscaling (tasks)
variable "ecs_tasks_min" {
  type    = number
  default = 1
}

variable "ecs_tasks_max" {
  type    = number
  default = 5
}

variable "alb_req_per_target_target_value" {
  type    = number
  default = 500
}

variable "scale_in_cooldown" {
  type    = number
  default = 120
}

variable "scale_out_cooldown" {
  type    = number
  default = 30
}
