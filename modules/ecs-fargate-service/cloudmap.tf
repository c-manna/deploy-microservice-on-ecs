resource "aws_service_discovery_service" "sd" {
  name = "${var.application}-${var.environment}-sd"  # Use a unique name for each environment or service
  dns_config {
    namespace_id = data.aws_service_discovery_dns_namespace.test.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

