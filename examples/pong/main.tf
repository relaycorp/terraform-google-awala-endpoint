module "self" {
  source = "../.."

  backend_name     = "pong"
  internet_address = var.internet_address

  project_id = var.google_project_id
  region     = var.google_region

  pohttp_server_domain = var.pohttp_server_domain

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.mongodb_db_name
  mongodb_user     = mongodbatlas_database_user.main.username
  mongodb_password = random_password.mongodb_user_password.result

  depends_on = [time_sleep.wait_for_services]
}
