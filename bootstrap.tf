resource "google_cloud_run_v2_job" "bootstrap" {
  name     = "awala-endpoint-${random_id.resource_suffix.hex}-bootstrap"
  location = var.region

  template {
    task_count = 1

    template {

      timeout = "300s"

      service_account = google_service_account.main.email

      execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

      max_retries = 1

      containers {
        name  = "bootstrap"
        image = "${var.docker_image_name}:${var.docker_image_tag}"

        args = ["pohttp-bootstrap"]

        env {
          name  = "INTERNET_ADDRESS"
          value = var.internet_address
        }

        env {
          name  = "ENDPOINT_VERSION"
          value = var.docker_image_tag
        }

        env {
          name  = "MONGODB_URI"
          value = var.mongodb_uri
        }
        env {
          name  = "MONGODB_DB"
          value = var.mongodb_db
        }
        env {
          name  = "MONGODB_USER"
          value = var.mongodb_user
        }
        env {
          name = "MONGODB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.mongodb_password.id
              version = "latest"
            }
          }
        }

        env {
          name  = "ACTIVE_ID_KEY_REF"
          value = google_kms_crypto_key_version.identity_key.id
        }
        env {
          name  = "ACTIVE_ID_PUBLIC_KEY"
          value = data.google_kms_crypto_key_version.identity_key.public_key[0].pem
        }

        env {
          name  = "PRIVATE_KEY_STORE_ADAPTER"
          value = "0"
        }

        // @relaycorp/awala-keystore-cloud options
        env {
          name  = "KMS_ADAPTER"
          value = "GCP"
        }
        env {
          name  = "KS_GCP_LOCATION"
          value = var.region
        }
        env {
          name  = "KS_KMS_KEYRING"
          value = google_kms_key_ring.keystores.name
        }
        env {
          name  = "KS_KMS_ID_KEY"
          value = google_kms_crypto_key.identity_key.name
        }
        env {
          name  = "KS_KMS_SESSION_ENC_KEY"
          value = google_kms_crypto_key.session_keys.name
        }

        // @relaycorp/webcrypto-kms options
        env {
          name  = "GCP_KMS_LOCATION"
          value = var.region
        }
        env {
          name  = "GCP_KMS_KEYRING"
          value = google_kms_key_ring.keystores.name
        }
        env {
          name  = "GCP_KMS_PROTECTION_LEVEL"
          value = var.kms_protection_level
        }

        env {
          name  = "LOG_TARGET"
          value = "gcp"
        }

        resources {
          limits = {
            cpu    = 1
            memory = "512Mi"
          }
        }
      }
    }
  }

  depends_on = [time_sleep.wait_for_id_key_creation]
  lifecycle {
    ignore_changes = [launch_stage]
  }
}

resource "google_service_account" "bootstraper" {
  project = var.project_id

  account_id  = "awala-endpoint-${random_id.resource_suffix.hex}-boot"
  description = "Used to run bootstrapping job"
}

resource "google_cloud_run_v2_job_iam_member" "bootstrapper" {
  project  = google_cloud_run_v2_job.bootstrap.project
  location = google_cloud_run_v2_job.bootstrap.location
  name     = google_cloud_run_v2_job.bootstrap.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.bootstraper.email}"
}

resource "google_service_account_iam_binding" "bootstraper_impersonation" {
  service_account_id = google_service_account.bootstraper.id
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${data.google_client_openid_userinfo.me.email}",
  ]
}

resource "time_sleep" "wait_for_bootstraper_impersonation" {
  depends_on      = [google_service_account_iam_binding.bootstraper_impersonation]
  create_duration = "10s"
}

data "google_service_account_access_token" "bootstrapper" {
  target_service_account = google_service_account.bootstraper.email
  scopes                 = ["userinfo-email", "cloud-platform"]

  depends_on = [time_sleep.wait_for_bootstraper_impersonation]
}

resource "null_resource" "detect_bootstrap_job_change" {
  triggers = {
    job_generation = google_cloud_run_v2_job.bootstrap.generation
  }
}

data "http" "bootstrap_executer" {
  // Only execute when job changes
  count = null_resource.detect_bootstrap_job_change.id == null ? 0 : 1

  url    = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.bootstrap.name}:run"
  method = "POST"

  request_headers = {
    "Authorization" = "Bearer ${data.google_service_account_access_token.bootstrapper.access_token}"
    "Content-Type"  = "application/json"
  }

  retry {
    attempts     = 1
    min_delay_ms = 3000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Bootstrap execution was rejected"
    }
    postcondition {
      condition     = google_cloud_run_v2_job.bootstrap.generation == lookup(lookup(lookup(jsondecode(self.response_body), "metadata"), "labels"), "run.googleapis.com/jobGeneration")
      error_message = "Executed wrong generation of bootstrap job"
    }
  }
}
