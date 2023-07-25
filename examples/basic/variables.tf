variable "google_project" {
  description = "Google project id"
}
variable "google_credentials_path" {
  description = "Path to Google credentials file"
}

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas public key"
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas private key"
  sensitive   = true
}

variable "mongodbatlas_project_id" {}

variable "pohttp_server_domain" {
  description = "Domain name for the PoHTTP server"
}
