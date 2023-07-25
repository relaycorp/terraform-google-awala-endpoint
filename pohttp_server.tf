resource "google_cloud_run_v2_service" "pohttp_server" {
  name     = "awala-endpoint-${random_id.resource_suffix.hex}-pohttp-server"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    timeout = "300s"

    service_account = google_service_account.endpoint.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = var.pohttp_server_max_instance_request_concurrency

    containers {
      name  = "pohttp-server"
      image = "${var.docker_image_name}:${var.docker_image_tag}"

      args = ["pohttp-server"]

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
        name  = "CE_TRANSPORT"
        value = "google-pubsub"
      }
      env {
        name  = "CE_GPUBSUB_TOPIC"
        value = google_pubsub_topic.incoming_messages.id
      }

      env {
        name  = "LOG_TARGET"
        value = "gcp"
      }

      env {
        name  = "REQUEST_ID_HEADER"
        value = "X-Cloud-Trace-Context"
      }

      resources {
        startup_cpu_boost = true
        cpu_idle          = false

        limits = {
          cpu    = var.pohttp_server_cpu_limit
          memory = "512Mi"
        }
      }

      startup_probe {
        initial_delay_seconds = 3
        failure_threshold     = 3
        period_seconds        = 10
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        failure_threshold     = 3
        period_seconds        = 20
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }
    }

    scaling {
      min_instance_count = var.pohttp_server_min_instance_count
      max_instance_count = var.pohttp_server_max_instance_count
    }
  }

  depends_on = [time_sleep.wait_for_id_key_creation]
}

resource "google_cloud_run_service_iam_member" "pohttp_server_public_access" {
  location = google_cloud_run_v2_service.pohttp_server.location
  project  = google_cloud_run_v2_service.pohttp_server.project
  service  = google_cloud_run_v2_service.pohttp_server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
