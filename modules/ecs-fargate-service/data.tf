data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster
}

data "aws_lb" "alb" {
  name = var.lb_name
}

data "aws_lb_listener" "listner" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 80
}

data "aws_region" "current" {}

# Private namespace for service discovery (Cloud Map)
data "aws_service_discovery_dns_namespace" "test" {
  name = var.cloudmap_namespace
  type = "DNS_PRIVATE"
}

# Subnets (used for Fargate awsvpc + optionally EC2 if you want)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Private subnets for EC2 instances (by tag pattern; adjust tags if needed)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Name = "*Private*"
  }
}

# ECS-Optimized AMI for EC2 mode
data "aws_ssm_parameter" "ecs_ami_al2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
