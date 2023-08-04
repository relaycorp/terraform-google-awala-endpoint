# Example use of the Awala Pong server behind an Awala Internet Endpoint middleware

This Terraform module integrates the [Awala Internet Endpoint](https://docs.relaycorp.tech/awala-endpoint-internet/) with the [Awala Pong server](https://github.com/relaycorp/awala-pong/) in a fully serverless environment on Google Cloud Platform and MongoDB Atlas.

## Prerequisites

- A GCP project with billing and the [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview) enabled.
- A domain name with DNSSEC correctly configured.
- A [MongoDB Atlas](https://www.mongodb.com/atlas/database) API key with the permissions `Organization Owner`, `Organization Member` and `Organization Read Only` on the project you wish to use.

## Instructions

1. Initialise this module with the required variables. For example:
   ```hcl
     module "awala-pong" {
       source  = "relaycorp/awala-endpoint/google//examples/pong"
       version = "<INSERT VERSION HERE>"
   
       google_project          = "your-project"
       google_credentials_path = "/home/you/Desktop/google-credentials.json"

       mongodbatlas_public_key  = "your-public-key-id"
       mongodbatlas_private_key = "your-private-key"
       mongodbatlas_project_id  = "your-project-id"

       internet_address     = "your-company.com"
       pohttp_server_domain = "awala-endpoint.your-company.com"
     }
   ```
2. Run `terraform init`, followed by `terraform apply`.
3. Execute the bootstrapping script as follows:
   ```shell
   gcloud --project=PROJECT --region=REGION run jobs execute \
     "$(terraform output bootstrap_job_name)" \
     --wait
   ```
4. Create the following DNS records:
   - `A` record for the load balancer, whose IPv4 address can be found in the output variable `pohttp_server_ip_address`.
   - `SRV` record for the A record above, so that it can be used as an _Awala Parcel-Delivery Connection (PDC)_ server. For example:
     ```
     _awala-pdc._tcp.your-company.com. 3600 IN SRV 0 0 443 pohttp-server.your-company.com.
     ```

## Test

1. Install the Awala Ping app for [Android](https://play.google.com/store/apps/details?id=tech.relaycorp.ping) or [desktop](https://www.npmjs.com/package/@relaycorp/awala-ping).
2. Download the connection parameters file from your Awala Internet Endpoint server. Its URL is `https://<POHTTP-SERVER-DOMAIN>/connection-params.der`.
3. Import the connection parameters file into the Awala Ping app.
   - On Android, open the endpoints by tapping the respective icon in the top-right corner, then tap the `+` button in the bottom-right corner, then select "Public endpoint", and finally select the DER file above and save.
   - On desktop, run `awala-ping third-party-endpoints import-public`. For example:
     ```shell
     awala-ping third-party-endpoints import-public < /path/to/connection-params.der
     ```
4. Send a ping and wait for a pong.
   - On Android, go back to the main screen and tap the "+ Ping" button. Then select the endpoint you just imported and tap the send button in to top-right corner.
   - On desktop, run `awala-ping ping`. For example:
     ```shell
     awala-ping ping your-company.com
     ```

If you don't get a pong within a few seconds, [check the logs](https://console.cloud.google.com/logs) and [whether any errors were reported](https://console.cloud.google.com/errors).

## Limitations

- This module does NOT restrict access to MongoDB from any particular IP address.
