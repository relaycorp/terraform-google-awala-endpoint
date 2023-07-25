module "load_balancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "9.1.0"

  project = var.project_id

  name = "awala-endpoint-${random_id.resource_suffix.hex}"

  ssl                             = true
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

resource "google_compute_region_network_endpoint_group" "main" {
  project = var.project_id
  region  = var.region

  name = "awala-endpoint-${random_id.resource_suffix.hex}"

  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.main.name
  }
}
