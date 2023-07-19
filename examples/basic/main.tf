terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.74.0"
    }
  }
}

locals {
  project_id = "tmp-tf-awala-endpoint"
}

module "self" {
  source = "../.."

  project_id = local.project_id

  depends_on = [google_project_service.services]
}
