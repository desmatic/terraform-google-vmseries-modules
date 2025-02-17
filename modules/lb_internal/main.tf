data "google_client_config" "this" {}

locals {
  # If we were told an exact region, use it, otherwise fall back to a client-default region
  region = coalesce(var.region, data.google_client_config.this.region)
}

resource "google_compute_health_check" "this" {
  name = "${var.name}-${local.region}-check-tcp${var.health_check_port}"
  project = var.project

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_region_backend_service" "this" {
  name   = var.name
  project = var.project
  region = local.region

  health_checks                   = [var.health_check != null ? var.health_check : google_compute_health_check.this.self_link]
  network                         = var.network
  session_affinity                = var.session_affinity
  timeout_sec                     = var.timeout_sec
  connection_draining_timeout_sec = var.connection_draining_timeout_sec

  dynamic "backend" {
    for_each = var.backends
    content {
      group    = backend.value
      failover = false
    }
  }

  dynamic "backend" {
    for_each = var.failover_backends
    content {
      group    = backend.value
      failover = true
    }
  }

  dynamic "failover_policy" {
    for_each = var.disable_connection_drain_on_failover != null || var.drop_traffic_if_unhealthy != null || var.failover_ratio != null ? ["one"] : []

    content {
      disable_connection_drain_on_failover = var.disable_connection_drain_on_failover
      drop_traffic_if_unhealthy            = var.drop_traffic_if_unhealthy
      failover_ratio                       = var.failover_ratio
    }
  }
}

resource "google_compute_forwarding_rule" "this" {
  name   = var.name
  project = var.project
  region = local.region

  load_balancing_scheme = "INTERNAL"
  ip_address            = var.ip_address
  ip_protocol           = var.ip_protocol
  all_ports             = var.all_ports
  ports                 = var.ports
  subnetwork            = var.subnetwork
  allow_global_access   = var.allow_global_access
  backend_service       = google_compute_region_backend_service.this.self_link
}
