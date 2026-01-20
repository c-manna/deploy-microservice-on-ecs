variable "application" { type = string }
variable "environment" { type = string }

# Choose: "FARGATE" or "EC2"
variable "compute_type" {
  type    = string
  default = "FARGATE"
  validation {
    condition     = contains(["FARGATE", "EC2"], upper(var.compute_type))
    error_message = "compute_type must be FARGATE or EC2"
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_id"      { type = string }
variable "ecs_cluster" { type = string }
variable "lb_name"     { type = string }

variable "ecr_repository_name" { type = string }
variable "container_version"   { type = string }

variable "log_group_name" { type = string }

variable "port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "health_check_path" {
   type = string
   default = "/"
 }
variable "path_pattern"      { 
  type = string 
  default = "/*" 
}

variable "cloudmap_namespace" { 
  type = string
  default = "corp"
}

variable "memory" { 
  type = number 
  default = 512 
}
variable "cpu"    { 
  type = number 
  default = 256 
}

# ECS Task autoscaling (tasks)
variable "ecs_tasks_min" { 
  type = number 
  default = 1 
}
variable "ecs_tasks_max" { 
  type = number 
  default = 5 
  }

variable "alb_req_per_target_target_value" { 
  type = number 
  default = 500 
}
variable "scale_in_cooldown"  { 
  type = number 
  default = 120
 }
variable "scale_out_cooldown" { 
  type = number
   default = 30 
}

# ---------------------------
# EC2 only settings
# ---------------------------
variable "ecs_instance_type" { 
  type = string 
  default = "t3.medium"
}
variable "ecs_instance_min"  { 
  type = number 
  default = 1
}
variable "ecs_instance_max"  { 
  type = number 
  default = 3 
}
variable "ecs_instance_desired" { 
  type = number 
  default = 1 
}

# Subnets for EC2 instances (if empty -> use private subnets auto)
variable "ecs_instance_subnet_ids" {
  type    = list(string)
  default = []
}

variable "ecs_instances_public_ip" {
  type    = bool
  default = false
}

variable "ecs_key_name" {
  type    = string
  default = null
}

# Capacity provider managed scaling target %
variable "capacity_provider_target_capacity" {
  type    = number
  default = 80
}
