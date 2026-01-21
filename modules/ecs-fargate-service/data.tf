data "aws_caller_identity" "current" {}

data "aws_vpc" "vpcid" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Name = "*Private*"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.ecs_cluster
}

data "aws_service_discovery_dns_namespace" "test" {
  name = var.cloudmap_namespace
  type = "DNS_PRIVATE"
}

data "aws_lb" "alb" {
  name = var.lb_name
}

data "aws_lb_listener" "listner" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 80
}

data "aws_region" "current" {}

# Latest ECS-Optimized Amazon Linux 2 AMI (recommended)
data "aws_ssm_parameter" "ecs_ami_al2" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Fetch Availability Zones for your region
data "aws_availability_zones" "available" {
  state = "available" # You can filter by 'available' state to get only the active AZs
}

# If you have private or public subnets defined in your VPC, you can fetch them here
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Name = "*Private*" # Update based on your actual tag filtering
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  # tags = {
  #   Name = "*Public*" # Update based on your actual tag filtering
  # }
}
