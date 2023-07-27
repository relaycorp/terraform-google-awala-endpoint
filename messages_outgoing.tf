resource "google_pubsub_topic" "outgoing_messages" {
  project = var.project_id

  name = "endpoint.${var.backend_name}.outgoing-messages"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_service_account" "pohttp_client_invoker" {
  account_id   = "endpoint-${var.backend_name}-pubsub"
  display_name = "Awala Internet Endpoint (${var.backend_name}), PoHTTP client invoker"
}

resource "google_cloud_run_service_iam_binding" "pohttp_client_invoker" {
  location = google_cloud_run_v2_service.pohttp_client.location
  service  = google_cloud_run_v2_service.pohttp_client.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.pohttp_client_invoker.email}"]
}

resource "google_project_service_identity" "pubsub" {
  provider = google-beta
  project  = var.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "pubsub_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub.email}"]
}

resource "google_pubsub_subscription" "outgoing_messages" {
  name  = "endpoint.${var.backend_name}.outgoing-messages"
  topic = google_pubsub_topic.outgoing_messages.name

  ack_deadline_seconds       = 10
  message_retention_duration = "259200s" # 3 days
  retain_acked_messages      = false
  expiration_policy {
    ttl = "" # Never expire
  }

  push_config {
    push_endpoint = google_cloud_run_v2_service.pohttp_client.uri
    oidc_token {
      service_account_email = google_service_account.pohttp_client_invoker.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "5s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.outgoing_messages_dead_letter.id
    max_delivery_attempts = 10
  }
}

resource "google_pubsub_topic" "outgoing_messages_dead_letter" {
  project = var.project_id

  name = "endpoint.${var.backend_name}.outgoing-messages.dead-letter"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_subscription_iam_binding" "outgoing_messages_dead_letter" {
  project = var.project_id

  subscription = google_pubsub_subscription.outgoing_messages.name
  role         = "roles/pubsub.subscriber"
  members      = ["serviceAccount:${google_project_service_identity.pubsub.email}", ]
}

resource "google_pubsub_topic_iam_binding" "outgoing_messages_dead_letter" {
  project = var.project_id

  topic   = google_pubsub_topic.outgoing_messages_dead_letter.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_project_service_identity.pubsub.email}", ]
}
