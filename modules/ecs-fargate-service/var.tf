variable "service_name" {
  default = ""
}

variable "vpc_id" {
  default = "vpc-0b6ca0870d2fff073"
}
variable "lb_name" {
  default = "dev-alb-hello-client"
}
variable "ecs_cluster" {
  default = "dev-cluster"
}
variable "region" {
  default = "ap-south-1"
}
variable "desired_count" {
  default = "1"
}
variable "app_definitions" {
  default = ""
}
variable "application" {
  default = ""
}
variable "environment" {
  default = ""
}
variable "container_version" {
  default = ""
}

variable "hosted_zone" {
  default = ""
}

variable "subdomain" {
  default = ""
}

variable "log_group_name" {
  default = ""
}
variable "ecr_repository_name" {
  default = ""
}

variable "port" {
  default = ""
}
variable "health_check_path" {
  default = "/"
}
variable "cloudmap_namespace" {
  default = "corp"
}
variable "path_pattern" {
  default = ""
}
variable "interval" {
  default = "50"
}
variable "timeout" {
  default = "25"
}
variable "unhealthy_threshold" {
  default = "5"
}
variable "memory" {
  type    = number
  default = 512
}
variable "cpu" {
  type    = number
  default = 256
}
variable "subdomain_cs" {
  default = ""
}
