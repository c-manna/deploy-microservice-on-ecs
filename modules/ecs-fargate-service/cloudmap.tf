resource "aws_service_discovery_service" "sd" {
  name = var.application

  dns_config {
    namespace_id = data.aws_service_discovery_dns_namespace.ns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  # failure_threshold is deprecated; omit
  health_check_custom_config {}
}
