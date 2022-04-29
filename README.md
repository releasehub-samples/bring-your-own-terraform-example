# Extending Release Environments with Terraform

[Release](https://releasehub.com/) allows you to quickly spin up full stack ephemeral and permanent environments in **your** cloud accounts.[Release Application Templates](https://docs.releasehub.com/reference-guide/application-settings/application-template) provide easy-to-use abstractions of cloud-native services to solve common environment needs, like the the ability to create an ephemeral RDS database cloned from a snapshot of your choice and attached to an environment with only two lines of YAML.

[Release Jobs](https://docs.releasehub.com/reference-guide/application-settings/application-template/schema-definition#jobs) also allow you to run any number of custom scripts as part of your environment's create, update, or teardown lifecycle. You define when and where such scripts run within the [Workflows](https://docs.releasehub.com/reference-guide/application-settings/application-template/schema-definition#jobs) section of your Application Template. to create a "hello world" Lambda function to execute custom Terraform as part of an ephemeral Release environment's create, update, and teardown lifecycle workflows.

In this project, we will show you how to extend your Release Environments with Terraform.


## What about Pulumi, CloudFormation, CDK, and others?

Release Jobs and Workflows can run any scripts or code that you can place in a Docker container. This means that you can adapt this project to support AWS CloudFormation, CDK, CloudFormation, Serverless Framework, Pulumi, and more. 


# Getting Started


### Release Account Requirements

Free-tier Release accounts may only launch up to two ephemeral environments in a Release-owned cloud account which does **not** include the ability to launch custom Terraform (or any other action that would require AWS or IAM privileges).

If you would like to a full-featured trial of using Release in _your_ cloud account (including Terraform support), [please contact us, here](https://releasehub.com). 


## Prerequisites

1. Release account connected to a [supported public cloud account](https://docs.releasehub.com/integrations/integrations-overview).

1. Previously-created Release Kubernetes cluster in the cloud account you want to use for deployment. 

1. Ability to create a new user or role in your cloud account.

1. Create an AWS role or GCP service account for Terraform. See [Granting permission to Terraform](#granting_permission_to_terraform) for detail.

1. **Optional** Install & configure the [Release CLI](https://cli.releasehub.com/).


## Selecting a project branch to deploy

The `main` branch of this repository contains setup and deployment instructions. 

Each other branch, like `aws-lambda` represents a standalone Terraform example you can deploy with Release.

The example branches are more or less identical apart from the Terraform resources created. 


## Deployment

1. Fork this repository to your GitHub, BitBucket, or GitLab account.

1. Within `./replease/application_template.yaml`, edit the `repo_name` to match your forked repository:

    ```yaml
    repo_name: <your_github_org_or_user>/release-with-terraform
    ```


1. Optional - if using the [Release CLI](https://cli.releasehub.com/), you can lint your `.release.yaml` (and Application Template + Environment Variables) using the command below:

    ```sh
    release gitops validate
    ```

### Architecture Deep Dive

This section provides a general overview of Release. Each project file includes comments to explain how things work.

## What is a Release Application? 

A `Release Application` is a colection of three things: 

1. pointer to a single repository in one of the [supported version control provider integrations](https://docs.releasehub.com/integrations/source-control-integrations), like GitHub. (Multi-repo suopport is available via [Release App Imports](https://docs.releasehub.com/examples/app-imports-connecting-two-apps-together)).

2. A [Release Application Template](https://docs.releasehub.com/reference-guide/application-settings/application-template) + [Release Default Environment Variables](https://docs.releasehub.com/reference-guide/application-settings/default-environment-variables) which together, are your "environment blueprint".

3. Any environment(s) instantiated from your repo and blueprint above. 

## Environment Lifecycle Hooks and Release Workflows

Whether permanent or ephemeral, a Release environment's lifecycle has three workflows:

* `setup` - when an environment is first created (e.g. via pull request, UI, CLI)

* `patch` - when an environment update / redeploy is triggered; you can choose between automatic updates upon pushing a commit or manually updating via the Release CLI or UI.

* `teardown` - when an environment is terminated by the user, or with ephemeral environments, when expired or when a PR is closed.

You use these environment lifecycle hooks within your **Application Template** (see below) to tell Release when, where, and how to create your environment.

## Application Template

The application template is a single, highly-abstracted YAML _environment-as-code_ definition that is tells Release everything it needs to know to create your environment. Two key components of the template include: 

1. Abstractions, like Release that make certain common patterns, like static sites, ephemeral clones of your existing databases, and containers on cloud-managed Kubernetes (EKS, GKE, etc.) as simple as Docker Compose. If deploying containers and using our Kuberenetes abstraction, you can reference Dockerfiles in your repo or external images in your cloud provider's container image repository (ECR, GCR, etc.), DockerHub, or Artifactory.

2. Flexibility to _extend_ Release by running **bring-your-own code** as part of any environment lifecycle workflow, including your existing infrastructure-as-code (e.g. Terraform, CDK, Pulumi, etc.).

3. Shortcuts to deploy Helm Charts, Kubernetes manifests, or Terraform. 

4. You can also package _any custom scripts or code you want_ into a Dockerfile and tell us to execute that script as a one-time (or cron) `job` in one of the lifecycle workflows of your Release Application Template. _This project demonstrates using custom Release jobs with Terraform to create ephemeral cloud resources._

## Granting Permission to Terraform

Release will execute your Terraform from within a container that was generated from the `Dockerfile` of the example you choose in the `examples/` directory, such as [examples/aws-s3-backend/Dockerfile](examples/aws-s3-backend/Dockerfile). 

Release will run this container from within the Release-managed Kubernetes cluster (EKS, GKE, etc.) that you select with the `context: <cluster_name>` in your `application_template.yaml` and the Terraform `init.sh` script ([example](examples/aws-s3-backend/bin/init.sh)) will include code to assume this identity to execute your Terraform.