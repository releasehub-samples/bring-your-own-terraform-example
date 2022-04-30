#!/bin/bash
set -e

# Name of the IAM role that is associated with your Release cluster's worker nodes.
# We will assume this role and inject it's temporary credentials into our local 
# container to simulate a container running on EKS in your account:
RELEASE_EKS_NODE_ROLE_NAME="eksctl-hubofhubs-release-us-west-NodeInstanceRole-PSJJECI9ZOYV"

REPO_ROOT_DIR=$(git rev-parse --show-toplevel)
THIS_FILE_DIR=$(dirname -- "$0")

# Run a local container with an interactive shell that simulates running in Release
# by parsing your environment_variables.yaml and injecting mock variables that 
# Release normally provides at run-time:

# TODO: adapt to read context from app template and do a build for each image:
PATH_TO_DOCKER_FILE="$REPO_ROOT_DIR/terraform" 
PATH_TO_LOCAL_ENV_VARS="$REPO_ROOT_DIR/test/local-vars-for-docker-run"             

# TODO: base this on the service name from app template once we parse it; e.g. release-{project_name?}-{service_name_from_app_template}
IMAGE_NAME="release-terraform-demo"

python3 "$THIS_FILE_DIR/generate-local-vars.py"
docker build -t $IMAGE_NAME $PATH_TO_DOCKER_FILE

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export ASSUME_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$RELEASE_EKS_NODE_ROLE_NAME"
export TEMP_ROLE=$(aws sts assume-role --role-arn "$ASSUME_ROLE_ARN" --role-session-name test --output json | jq -r '.Credentials')

export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.SessionToken')

docker run --rm -it --env-file $PATH_TO_LOCAL_ENV_VARS \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -e AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
    --entrypoint bash $IMAGE_NAME

