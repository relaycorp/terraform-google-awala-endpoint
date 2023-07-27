locals {
  project_id = "tmp-tf-awala-endpoint"
  gcp_region = "europe-west1"
}

module "self" {
  source = "../.."

  backend_name     = "example"
  internet_address = "example.com"

  project_id = local.project_id
  region     = local.gcp_region

  pohttp_server_domain = var.pohttp_server_domain

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.mongodb_db_name
  mongodb_user     = mongodbatlas_database_user.main.username
  mongodb_password = random_password.mongodb_user_password.result

  depends_on = [google_project_service.services]
}
