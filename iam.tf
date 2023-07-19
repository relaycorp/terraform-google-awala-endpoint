resource "google_service_account" "endpoint" {
  project = var.project_id

  account_id = "awala-endpoint-${random_id.resource_suffix.hex}"
}
