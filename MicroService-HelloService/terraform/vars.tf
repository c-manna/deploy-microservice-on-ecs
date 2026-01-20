variable "region" {
  default = "ap-south-1"
}

variable "environment" {
  default = "dev"
}
variable "cloudmap_namespace"{
  default =""
}

variable "application" {
  default = "hello"
}

variable "vpc_id" {
  default = ""
}

variable "container_version" {
  default = ""
}

variable "compute_type" {
  type    = string
  default = "FARGATE"
}

# EC2 mode only
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

# Task autoscaling (works for both)
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
