resource "google_service_account" "main" {
  project = var.project_id

  account_id   = "endpoint-${var.backend_name}"
  display_name = "Awala Internet Endpoint (${var.backend_name})"
}
