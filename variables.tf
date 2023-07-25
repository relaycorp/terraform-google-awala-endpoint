variable "internet_address" {
  description = "The Awala Internet address of the endpoint (e.g., 'example.com')"
  type        = string
}

variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "docker_image_name" {
  description = "The Docker image to deploy"
  default     = "relaycorp/awala-endpoint-tmp"
}

variable "docker_image_tag" {
  description = "The Docker image tag to deploy"
  default     = "020"
}

variable "kms_protection_level" {
  description = "The KMS protection level (SOFTWARE or HSM)"
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.kms_protection_level)
    error_message = "KMS protection level must be either SOFTWARE or HSM"
  }
}

variable "mongodb_uri" {
  description = "The MongoDB URI"
  type        = string
}
variable "mongodb_db" {
  description = "The MongoDB database name"
  type        = string
}
variable "mongodb_user" {
  description = "The MongoDB username"
  type        = string
}
variable "mongodb_password" {
  description = "The MongoDB password"
  type        = string
  sensitive   = true
}

variable "pohttp_server_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the PoHTTP server)"
  type        = number
  default     = 80
}
variable "pohttp_server_min_instance_count" {
  description = "The minimum number of instances (for the PoHTTP server)"
  type        = number
  default     = 1
}
variable "pohttp_server_max_instance_count" {
  description = "The maximum number of instances (for the PoHTTP server)"
  type        = number
  default     = 3
}
variable "pohttp_server_cpu_limit" {
  description = "The maximum vCPUs allocated to each instance of the PoHTTP server"
  type        = number
  default     = 2
}
