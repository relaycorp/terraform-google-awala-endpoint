terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.74.0"
    }
  }
}

resource "random_id" "resource_suffix" {
  byte_length = 3
}

data "google_client_openid_userinfo" "me" {
}
