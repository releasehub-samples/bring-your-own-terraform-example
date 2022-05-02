# Extending Release Environments with Terraform

[Release](https://releasehub.com/) allows you to quickly spin up full stack ephemeral and permanent environments in **your** cloud account.

This project will show you how to extend Release environments with bring-your-own Terraform.

## What about Pulumi, CloudFormation, CDK, and others?

Release Jobs and Workflows can run any scripts or code that you can place in a Docker container. This means that you can adapt this project to support AWS CloudFormation, CDK, CloudFormation, Serverless Framework, Pulumi, and more. 


# Getting Started


### Release Account Requirements

Free-tier Release accounts may only launch up to two ephemeral environments in a Release-owned cloud account which does **not** include the ability to launch custom Terraform (or any other action that would require AWS or IAM privileges).

If you would like to a full-featured trial of using Release in _your_ cloud account (including Terraform support), [please contact us, here](https://releasehub.com). 


## Prerequisites

1. Release account connected to a [supported public cloud account](https://docs.releasehub.com/integrations/integrations-overview).

1. Previously-created Release Kubernetes cluster in the cloud account you want to use for deployment. 

1. Create an AWS role or GCP service account for Terraform and an S3 or GCS bucket to store your state files. See [Granting permission to Terraform](#granting_permission_to_terraform) for detail.

1. **Optional** Install & configure the [Release CLI](https://cli.releasehub.com/).


## Deployment

1. Fork this repository to your GitHub, BitBucket, or GitLab account.

1. Complete the [prerequisites](#prerequisites) on the `main` branch.

1. Switch to the branch of the demo you'd like to use (e.g. `git checkout aws-lambda`).

1. Complete any remaining deployment steps on the branch you've checked out. 


## Granting Permission to Terraform

Release will run your Terraform within the context of a Docker container, which means the container will need IAM / role credentials to create, update, delete, and list resources in your account, as well as read/write state files to a destination like Amazon S3 Google GCS. 

You can run `./prerequisites/cloudformation.yaml` to create an S3 bucket and a "starter" role for Terraform; though you will need to add permissions to this role for most Terraform activity. Make note of the role name that gets created, you will plug this in to later steps. 