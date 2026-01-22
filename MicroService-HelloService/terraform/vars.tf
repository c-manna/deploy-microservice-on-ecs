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

variable "ecs_tasks_min" {
  type    = number
  default = 1
}

variable "ecs_tasks_max" {
  type    = number
  default = 5
}

variable "alb_req_per_target_target_value" {
  description = "The target value for the Application Load Balancer request per target"
  type        = number
  default     = 100
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scaling out"
  type        = number
  default     = 30
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scaling in"
  type        = number
  default     = 120
}