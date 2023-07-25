locals {
  services = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "services" {
  for_each = toset(local.services)

  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = true
}