terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.75.0, < 7.0.0"
    }
  }
}

resource "random_id" "unique_suffix" {
  byte_length = 3
}
