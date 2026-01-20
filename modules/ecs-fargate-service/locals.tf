locals {
  compute = upper(var.compute_type)

  is_fargate = local.compute == "FARGATE"
  is_ec2     = local.compute == "EC2"

  service_name = "${var.application}-${var.environment}"
}
