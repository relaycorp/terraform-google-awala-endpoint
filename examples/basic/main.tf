locals {
  project_id = "tmp-tf-awala-endpoint"
  gcp_region = "europe-west1"
}

module "self" {
  source = "../.."

  project_id = local.project_id
  region     = local.gcp_region

  depends_on = [google_project_service.services]
}
