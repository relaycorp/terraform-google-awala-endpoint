output "service_account_email" {
  value = google_service_account.main.email
}

output "pubsub_topics" {
  value = {
    "incoming_messages" = google_pubsub_topic.incoming_messages.name
    "outgoing_messages" = google_pubsub_topic.outgoing_messages.name
  }
}

output "bootstrap_job_name" {
  value = google_cloud_run_v2_job.bootstrap.name
}

output "pohttp_server_ip_address" {
  value = module.load_balancer.external_ip
}
