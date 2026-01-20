# SG for ECS tasks (Fargate uses this; EC2 bridge mode doesn't need per-task SG)
resource "aws_security_group" "task_sg" {
  count  = local.is_fargate ? 1 : 0
  name   = "${local.service_name}-task-sg"
  vpc_id = data.aws_vpc.vpc.id

  # Allow ALB -> tasks on container port
  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = data.aws_lb.alb.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for ECS EC2 instances (only EC2 mode)
resource "aws_security_group" "ecs_instance_sg" {
  count  = local.is_ec2 ? 1 : 0
  name   = "${local.service_name}-ecs-instance-sg"
  vpc_id = data.aws_vpc.vpc.id

  # ALB -> instances ephemeral ports (bridge + dynamic host ports)
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = data.aws_lb.alb.security_groups
  }

  # Optional internal access inside VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
