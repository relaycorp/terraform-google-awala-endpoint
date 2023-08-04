resource "google_service_account" "pong_invoker" {
  project = local.project_id

  account_id   = "awala-pong-pubsub"
  display_name = "Awala Pong, Cloud Run service invoker"
}

resource "google_cloud_run_service_iam_binding" "pong_invoker" {
  project = local.project_id

  location = google_cloud_run_v2_service.pong.location
  service  = google_cloud_run_v2_service.pong.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.pong_invoker.email}"]
}

resource "google_pubsub_subscription" "incoming_messages" {
  project = local.project_id

  name  = "pong.incoming-pings"
  topic = module.self.pubsub_topics.incoming_messages

  ack_deadline_seconds       = 10
  message_retention_duration = "259200s" # 3 days
  retain_acked_messages      = false
  expiration_policy {
    ttl = "" # Never expire
  }

  push_config {
    push_endpoint = google_cloud_run_v2_service.pong.uri
    oidc_token {
      service_account_email = google_service_account.pong_invoker.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "5s"
  }
}
