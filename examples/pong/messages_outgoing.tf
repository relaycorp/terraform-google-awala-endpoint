resource "google_pubsub_topic_iam_binding" "outgoing_messages_publisher" {
  project = local.project_id

  topic   = module.self.pubsub_topics.outgoing_messages
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_service_account.pong.email}", ]
}
