# Extending Release Environments with Terraform

[Release](https://releasehub.com/) allows you to quickly spin up full stack ephemeral and permanent environments in your public cloud account. As of April 2022, Release supports AWS and GCP, and in addition to the abstractions Release gives you for common environment components like container service, you can extend your environmenet by running any custom infrastructure-as-code (IaC) during an environment's create, update, and teardown workflows.

This project shows you how to include any service offerred by your cloud provider and supported by Terraform as part of an ephemeral or permanent [Release environment]([Release](https://releasehub.com/)).


# Getting Started

### Release Account Requirements

Free-tier Release accounts may only launch up to two ephemeral environments in a Release-owned cloud account which does **not** include the ability to launch custom Terraform (or any other action that would require AWS or IAM privileges).

If you would like to a full-featured trial of using Release in _your_ cloud account (including Terraform support), [please contact us here](https://releasehub.com). 

## Prerequisites

1. Release account connected to a [supported public cloud provider](https://docs.releasehub.com/integrations/integrations-overview).

1. Ability to create an AWS IAM role or a GCP service account in your cloud account.

1. Release-managed Kubernetes cluster (EKS, GKE, or AKS) that you created using Release. 

1. [Optional] Release CLI([Release CLI](https://cli.releasehub.com/)).


## Projects

[Release Jobs](https://docs.releasehub.com/reference-guide/application-settings/application-template/schema-definition#jobs) allow you to run arbitrary scripts during an environments setup, patch, and teardown flows of your Application Template's [Workflows](https://docs.releasehub.com/reference-guide/application-settings/application-template/schema-definition#jobs) section. to create a "hello world" Lambda function to execute custom Terraform as part of an ephemeral Release environment's create, update, and teardown lifecycle workflows.
<!--
// TODO: Finish the cloud backend
 * [examples/aws-cloud-backend](examples/aws-cloud-backend) - [work in process]
-->
* [examples/aws-s3-backend](examples/aws-s3-backend) - demo using S3 to store Terraform state files.


## Deploying with Release

1. Create an AWS IAM role (or GCP service account, etc.) with the permission(s) needed by Terraform to create your stack. Refer to [Granting permission to Terraform](#granting_permission_to_terraform) for detail.

1. Fork this repository

1. You can safely make changes to the `main` branch, though you can _optionally_ checkout a new branch, such as:

    ```sh
    git checkout -b test_release
    ```

1. Edit [.release.yaml] to point to the example directory of the project you want to test:

    ```yaml
    application_template: examples/aws-s3-backend/.release/application_template.yaml
    environment_variables: examples/aws-s3-backend/.release/environment_variables.yaml
    ```
1. Within the `application_template.yaml` that you choose to deploy, edit the `repo_name` to match your forked repository:

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