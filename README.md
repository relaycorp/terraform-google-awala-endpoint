# terraform-google-awala-endpoint

Terraform module to manage an instance of the Awala Internet Endpoint on GCP.

![](./diagrams/cloud.svg)

## Requirements

- Enable the [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview) for your project.

## Instructions

- `terraform apply`
- Run the bootstrapping script using:
  ```shell
  gcloud --project=PROJECT --region=REGION run jobs execute \
    "$(terraform output bootstrap_job_name)" \
    --wait
  ```

## Dead lettering

TODO
