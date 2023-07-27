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

  depends_on = [
    time_sleep.wait_for_id_key_creation,
    google_secret_manager_secret_iam_binding.mongodb_password_reader,
  ]
  lifecycle {
    ignore_changes = [launch_stage]
  }
}
