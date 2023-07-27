terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.74.0"
    }
  }
}

resource "random_id" "unique_suffix" {
  byte_length = 3
}
