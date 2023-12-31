resource "google_pubsub_topic" "incoming_messages" {
  project = var.project_id

  name = "endpoint.${var.backend_name}.incoming-messages"

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_topic_iam_binding" "incoming_messages_publisher" {
  project = var.project_id

  topic   = google_pubsub_topic.incoming_messages.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_service_account.main.email}", ]
}
