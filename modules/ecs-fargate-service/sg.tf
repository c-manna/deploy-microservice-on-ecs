resource "aws_security_group" "ecs_instance_sg" {
  name   = "${var.application}-${var.environment}-ecs-ec2-sg"
  vpc_id = data.aws_vpc.vpcid.id

  # Allow ALB -> ECS instances on ECS ephemeral ports (bridge mode + dynamic host ports)
  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = data.aws_lb.alb.security_groups
  }

  # Allow internal VPC traffic (service-to-service if needed)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpcid.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
