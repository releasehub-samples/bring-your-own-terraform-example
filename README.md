# Extending Release Environments with Terraform

## AWS Lambda Example

This branch provides an example of using Release to create an ephemeral Amazon ECS container service with bring-your own Terraform.

## Prerequisites

The `main` branch contains an overview of how this project works and required pre-requisites that must be completed before deploying this branch to a Release environment. 

## Deployment

### Deploy as cloud environment with Release

Refer to the `main` branch for deployment instructions.

### Test locally as a container

You can run a local Docker container to mimick the way Release will run your Terraform container in a real environment. 

1. Complete any prerequisites on described on the `main` branch of this repo. 

1. Install Python 3.10 or above. `pyenv-virtualenv` is a nice utility for switching python versions and virtual environments.

1. Install Python dependencies: 

    ```sh
    cd test/
    pip install -r requirements.txt
    ```

1. Optionally, update the values in `./release/environment_variables.yaml` as needed for your tests.

1. From within your AWS account, navigate to either the EKS or IAM web console and find the IAM role used by worker nodes in your cluster. Make note of the role's name, which will follow a pattern like this: 

    ```sh
    eksctl-<name_of_your_cluster>-NodeInstanceRole-<random_chars>
    ```

    Then, update the value found in `test/run-local-container.sh`:

    ```sh
    RELEASE_EKS_NODE_ROLE_NAME="eksctl-<your_role_name>-NodeInstanceRole-<some_values>"
    ```

1. From the root of this repository, run:

    ```sh
    ./bin/run-local-container.sh
    ```

    This will build and run a docker container from your /terraform directory that simulates running your container in a Release-managed EKS cluster in your account: From there, you can test your Terraform:

    ```sh
    ./bin/apply.sh
    ./bin/destroy.sh
    ```

## Terraform Lock File Management

The `./terraform.lock.hcl` file can either be committed to your repo to maintain consistent module versions or it can be ignored to allow `terraform init` to pull the latest module versions with each run. 

There are trade-offs with either approach, though this author personally prefers consistency and chooses to commit this file to source control.