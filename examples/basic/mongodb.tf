locals {
  mongodb_db_name = "main"
}

resource "mongodbatlas_serverless_instance" "main" {
  project_id = var.mongodbatlas_project_id
  name       = "awala-endpoint"

  provider_settings_backing_provider_name = "GCP"
  provider_settings_provider_name         = "SERVERLESS"
  provider_settings_region_name           = "WESTERN_EUROPE"
}

resource "mongodbatlas_database_user" "main" {
  project_id = var.mongodbatlas_project_id

  username           = "awala-endpoint"
  password           = random_password.mongodb_user_password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = mongodbatlas_serverless_instance.main.name
  }
}

resource "random_password" "mongodb_user_password" {
  length = 32
}

resource "google_secret_manager_secret" "main" {
  project = local.project_id

  secret_id = "awala_endpoint-mongodb_password"

  replication {
    user_managed {
      replicas {
        location = local.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "main" {
  secret      = google_secret_manager_secret.main.id
  secret_data = random_password.mongodb_user_password.result
}
