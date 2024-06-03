module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "11.0.0"

  project = var.project_id

  name = "endpoint-${var.backend_name}"

  ssl                             = true
  ssl_policy                      = google_compute_ssl_policy.main.id
  random_certificate_suffix       = true # In case the domain changes
  managed_ssl_certificate_domains = [var.pohttp_server_domain]

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.main.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }

  http_forward = false
}

resource "google_compute_ssl_policy" "main" {
  name            = "endpoint-${var.backend_name}"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_region_network_endpoint_group" "main" {
  project = var.project_id
  region  = var.region

  name = "endpoint-${var.backend_name}"

  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.pohttp_server.name
  }
}
