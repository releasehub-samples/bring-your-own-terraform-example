# Extending Release Environments with Terraform

This project includes multiple examples of extending ephemeral [Release environments]([Release](https://releasehub.com/)) with bring-your-own Terraform.


## Projects

This repo demonstrates using Release `jobs` to create a "hello world" Lambda function to execute custom Terraform as part of an ephemeral Release environment's create, update, and teardown lifecycle workflows.

* [examples/aws-s3-backend](examples/aws-s3-backend) - demo using S3 to store Terraform state files. 

* [examples/aws-cloud-backend](examples/aws-cloud-backend) - [work in process]

## Deploying with Release

1. Fork this repository

2. Edit [.release.yaml] to point to the example directory of the project you want to test:

    ```yaml
    application_template: examples/aws-s3-backend/.release/application_template.yaml
    environment_variables: examples/aws-s3-backend/.release/environment_variables.yaml
    ```


### Release Overview

## What is a Release Application? 

[Release](https://releasehub.com/) allows you to quickly spin up full stack ephemeral and permanent environments in your public cloud account. A `Release Application` is a colection of three things: 

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

