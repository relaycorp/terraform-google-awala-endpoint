# `relaycorp/awala-endpoint`

This is a Terraform module to manage an instance of the [Awala Internet Endpoint](https://docs.relaycorp.tech/awala-endpoint-internet/) on Google Cloud Platform (GCP) using serverless services in the same region.

The module is responsible for all the resources needed to run the endpoint app on GCP, except for the following (which you can deploy to any cloud and any region):

- The backend app.
- The MongoDB server.
- The DNS records.

The following diagram illustrates the cloud architecture created by this module:

![](./diagrams/cloud.svg)

## Prerequisites

- A GCP project with billing and the [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview) enabled.
- A domain name with DNSSEC correctly configured.
- A MongoDB server reachable from the Cloud Run resources.
- The backend app (which will communicate with the endpoint via Google Pub/Sub).

## Instructions

- Initialise this module in a new module.
  ```hcl
    module "awala-endpoint" {
      source  = "relaycorp/awala-endpoint/google"
      version = "<INSERT VERSION HERE>"
  
      # ... Specify the variables here..
    }
  ```
  [See full example](examples/basic).
- Run `terraform init`, followed by `terraform apply`.
- Finally, execute the bootstrapping script as follows:
  ```shell
  gcloud --project=PROJECT --region=REGION run jobs execute \
    "$(terraform output bootstrap_job_name)" \
    --wait
  ```

## Dead lettering

PubSub is configured to attempt to deliver messages to Awala Internet Gateways up to 10 times. When this limit is reached, the message is moved to a [dead letter topic](https://www.enterpriseintegrationpatterns.com/patterns/messaging/DeadLetterChannel.html).

The name of the dead letter topic is available as the output variable `pubsub_topics.outgoing_messages_dead_letter`. [Refer to the GCP documentation to learn how to handle such messages](https://cloud.google.com/pubsub/docs/handling-failures).
