#!/bin/bash
set -e

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
export TF_VAR_BACKEND_KEY="release/$TF_VAR_RELEASE_APP_NAME/$TF_VAR_RELEASE_BRANCH_NAME/$TF_VAR_RELEASE_ENV_ID/tfstate"

# Set up our backend state file in S3: 
terraform init -migrate-state -force-copy \
    -backend-config="key=$TF_VAR_BACKEND_KEY" \
    -backend-config="bucket=$TF_VAR_BACKEND_BUCKET" \
    -backend-config="region=$TF_VAR_BACKEND_REGION"

