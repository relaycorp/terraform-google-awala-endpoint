resource "google_service_account" "main" {
  project = var.project_id

  account_id   = "awala-endpoint-${random_id.resource_suffix.hex}"
  display_name = "Awala Internet Endpoint (${random_id.resource_suffix.hex})"
}
