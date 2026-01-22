# -----------------------------
# Task execution role (same idea as before)
# -----------------------------
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole-${var.application}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

data "aws_iam_policy_document" "assume_role_policy_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# (You attached AdminAccess earlier; keep only if you really need it)
resource "aws_iam_role_policy_attachment" "task_admin_access" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# -----------------------------
# EC2 container instance role/profile (NEW)
# -----------------------------
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole-${var.application}-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ec2.json
}

data "aws_iam_policy_document" "assume_role_policy_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Required for ECS container instances
resource "aws_iam_role_policy_attachment" "ecs_instance_ecs_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Optional but strongly recommended for debugging/ops
resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile-${var.application}-${var.environment}"
  role = aws_iam_role.ecs_instance_role.name
}
