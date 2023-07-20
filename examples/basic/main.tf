locals {
  project_id = "tmp-tf-awala-endpoint"
  gcp_region = "europe-west1"
}

module "self" {
  source = "../.."

  project_id = local.project_id
  region     = local.gcp_region

  mongodb_uri = mongodbatlas_serverless_instance.main.connection_strings_standard_srv

  mongodb_user                    = mongodbatlas_database_user.main.username
  mongodb_password_secret_version = google_secret_manager_secret_version.mongodb_password.id

  depends_on = [google_project_service.services]
}
