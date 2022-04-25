#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
TF_VAR_DEPLOYMENT_ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/release/$TF_VAR_DEPLOYMENT_ROLE_NAME"

# Assume the role needed to read/write backend state and deploy stuff with terraform:
aws_credentials=$(aws sts assume-role --role-arn $TF_VAR_DEPLOYMENT_ROLE_ARN --role-session-name "release-$TF_VAR_RELEASE_APP_NAME-$TF_VAR_RELEASE_ENV_ID-terraform")
export AWS_ACCESS_KEY_ID=$(echo $aws_credentials|jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $aws_credentials|jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $aws_credentials|jq -r '.Credentials.SessionToken')

# Required for automation - Prevent interactive prompts for variables without a specified value:
export TF_INPUT=0

# Optional - Prevent Terraform CLI commands from outputting suggestions that are not helpful to automation:
export TF_IN_AUTOMATION=true

# Determine the S3 object key to which we will write/update Terraform state: 
export TERRAFORM_STATE_OBJECT_KEY="release/$TF_VAR_RELEASE_APP_NAME/$TF_VAR_RELEASE_BRANCH_NAME/$TF_VAR_RELEASE_ENV_ID/tfstate"

# Set up our backend state file in S3: 
terraform init -migrate-state -force-copy \
    -backend-config="key=$TERRAFORM_STATE_OBJECT_KEY" \
    -backend-config="bucket=$TERRAFORM_STATE_BUCKET_NAME_PREFIX" \
    -backend-config="region=$TERRAFORM_STATE_BUCKET_REGION"

