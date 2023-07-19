locals {
  project_id = "tmp-tf-awala-endpoint"
}

module "self" {
  source = "../.."

  project_id = local.project_id
  region     = "europe-west1"

  depends_on = [google_project_service.services]
}
