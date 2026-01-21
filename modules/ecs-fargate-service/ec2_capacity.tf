locals {
  instance_subnets = length(var.ecs_instance_subnet_ids) > 0 ? var.ecs_instance_subnet_ids : data.aws_subnets.private.ids
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.application}-${var.environment}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami_al2.value
  instance_type = var.ecs_instance_type
  key_name      = var.ecs_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.ecs_instance_sg.id]
    associate_public_ip_address = var.ecs_instances_public_ip
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${var.ecs_cluster}" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_TASK_ENI=false" >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.application}-${var.environment}-ecs-instance"
    }
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.application}-${var.environment}-ecs-asg"
  min_size            = var.ecs_instance_min
  max_size            = var.ecs_instance_max
  desired_capacity    = var.ecs_instance_desired
  vpc_zone_identifier = local.instance_subnets

  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.application}-${var.environment}-ecs-asg"
    propagate_at_launch = true
  }

  # Important: this tag helps identify ECS instances
  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "${var.application}-${var.environment}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = var.capacity_provider_target_capacity
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 5
      instance_warmup_period    = 300
    }

    managed_termination_protection = "DISABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = data.aws_ecs_cluster.cluster.cluster_name

  capacity_providers = [
    aws_ecs_capacity_provider.ec2.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
    base              = 1
  }
}
