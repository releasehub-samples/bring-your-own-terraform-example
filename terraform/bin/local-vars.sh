#!/bin/bash
set -e

echo "Terraform is running outside of a Release environment, loading dummy variables..."

# Setting to any value signals that this is a local environment
IS_RELEASE_ENV=false

export RELEASE_ACCOUNT_ID=2884
export RELEASE_APP_NAME=terraform-with-release
export RELEASE_BRANCH_NAME=ecs
export RELEASE_CLOUD_PROVIDER=aws
export RELEASE_CLUSTER_REGION=us-west-2
export RELEASE_COMMIT_SHA=ff512a17f83ef53e623d25a870287d0a221430cc
export RELEASE_COMMIT_SHORT=0ad6025b
export RELEASE_ENV_ID=ted52db
export RELEASE_RANDOMNESS=ted52db
export TERRAFORM_COMMIT_SHA=ff512a17f83ef53e623d25a870287d0a221430cc
export TERRAFORM_COMMIT_SHORT=0ad6025b
export TERRAFORM_DEPLOYMENT_ROLE_NAME="release/demo_role_for_terraform_job"
export TERRAFORM_REGISTRY_IMAGE_SHA=6e08b7354dfd7e2b6926489f2808081ce28d8dd988d799ddc19044c2fa445986
export TERRAFORM_STATE_BUCKET_NAME_PREFIX=release-demo-of-terraform
export TERRAFORM_STATE_BUCKET_REGION=us-west-2
export TF_VAR_AWS_DEFAULT_REGION=us-west-2
export TF_VAR_RELEASE_ACCOUNT_ID=2884
export TF_VAR_RELEASE_APP_NAME=terraform-with-release
export TF_VAR_RELEASE_BRANCH_NAME=ecs
export TF_VAR_RELEASE_COMMIT_SHA=ff512a17f83ef53e623d25a870287d0a221430cc
export TF_VAR_RELEASE_COMMIT_SHORT=0ad6025b
export TF_VAR_RELEASE_ENV_ID=ted52db