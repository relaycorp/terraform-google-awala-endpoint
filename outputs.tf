output "pubsub_topics" {
  value = {
    "incoming_messages"             = google_pubsub_topic.incoming_messages.name
    "outgoing_messages"             = google_pubsub_topic.outgoing_messages.name
    "outgoing_messages_dead_letter" = google_pubsub_topic.outgoing_messages_dead_letter.name
  }
}

output "bootstrap_job_name" {
  value = google_cloud_run_v2_job.bootstrap.name
}

output "pohttp_server_ip_address" {
  value = module.load_balancer.external_ip
}
