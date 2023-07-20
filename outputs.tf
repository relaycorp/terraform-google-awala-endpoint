output "service_account_email" {
  value = google_service_account.endpoint.email
}

output "pubsub_topics" {
  value = {
    "incoming_messages" = google_pubsub_topic.incoming_messages.name
    "outgoing_messages" = google_pubsub_topic.outgoing_messages.name
  }
}
