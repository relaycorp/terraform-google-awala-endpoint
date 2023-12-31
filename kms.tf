// See https://docs.relaycorp.tech/awala-keystore-cloud-js/gcp

resource "google_kms_key_ring" "keystores" {
  project = var.project_id

  # Key rings can be deleted from the Terraform state but not GCP, so let's add a suffix in case
  # we need to recreate it.
  name = "endpoint-${var.backend_name}-${random_id.unique_suffix.hex}"

  location = var.region
}

resource "random_id" "key_suffix" {
  byte_length = 3

  keepers = {
    kms_protection_level = var.kms_protection_level
  }
}

resource "google_kms_crypto_key" "identity_key" {
  name     = "identity-key-${random_id.key_suffix.hex}"
  key_ring = google_kms_key_ring.keystores.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm        = "RSA_SIGN_PSS_2048_SHA256"
    protection_level = var.kms_protection_level
  }

  lifecycle {
    prevent_destroy = false
  }
}

// Ideally, we'd just manage the key version explicitly, but we can't due to two limitations
// in the Google provider:
// 1.- This bug with HSM keys: https://github.com/hashicorp/terraform-provider-google/issues/13924
// 2.- The lack of support for reading the public key as soon as the key is created.
data "google_kms_crypto_key_version" "initial_identity_key" {
  crypto_key = google_kms_crypto_key.identity_key.id

  depends_on = [time_sleep.wait_for_id_key_creation]
}

resource "google_kms_crypto_key" "session_keys" {
  name            = "session-keys-${random_id.key_suffix.hex}"
  key_ring        = google_kms_key_ring.keystores.id
  rotation_period = "2592000s" // 30 days
  purpose         = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.kms_protection_level
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "time_sleep" "wait_for_id_key_creation" {
  depends_on      = [google_kms_crypto_key.identity_key]
  create_duration = "30s"

  triggers = {
    kms_protection_level = var.kms_protection_level
  }
}

// IAM
// https://docs.relaycorp.tech/awala-keystore-cloud-js/gcp#iam-permissions

resource "google_project_iam_custom_role" "keystore_kms_admin" {
  project = var.project_id

  role_id = "awala_endpoint.keystore_kms_manager"
  title   = "Permissions to manage KMS resources related to the Awala keystore"
  permissions = [
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeyVersions.create",
  ]
}

resource "google_project_iam_binding" "keystore_kms_admin" {
  project = var.project_id

  role = google_project_iam_custom_role.keystore_kms_admin.id

  members = ["serviceAccount:${google_service_account.main.email}"]

  condition {
    title      = "Limit app access to KMS key ring"
    expression = "resource.name.startsWith(\"${google_kms_key_ring.keystores.id}\")"
  }
}

resource "google_project_iam_member" "keystore_kms_user" {
  project = var.project_id

  role   = "roles/cloudkms.cryptoOperator"
  member = "serviceAccount:${google_service_account.main.email}"

  condition {
    title      = "Limit app access to KMS key ring"
    expression = "resource.name.startsWith(\"${google_kms_key_ring.keystores.id}\")"
  }
}
