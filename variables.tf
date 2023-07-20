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
  default     = "017"
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

variable "mongodb_user" {
  description = "The MongoDB username"
  type        = string
}

variable "mongodb_password" {
  description = "The id of the Secrets Manager secret version containing the MongoDB password"
  type        = string
  sensitive   = true
}
