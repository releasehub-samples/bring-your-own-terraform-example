#!/bin/bash
set -e

echo "[BEGIN TERRAFORM INIT]"

export ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "AWS Account ID = $ACCOUNT_ID"

export DEPLOYMENT_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${TERRAFORM_DEPLOYMENT_ROLE_NAME}"
echo "Assuming role $DEPLOYMENT_ROLE_ARN..."
# Assume the role needed to read/write backend state and deploy stuff with terraform:
aws_credentials=$(aws sts assume-role --role-arn $DEPLOYMENT_ROLE_ARN --role-session-name "release-$RELEASE_APP_NAME-$RELEASE_ENV_ID-terraform")
export AWS_ACCESS_KEY_ID=$(echo $aws_credentials|jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $aws_credentials|jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $aws_credentials|jq -r '.Credentials.SessionToken')

# Required for automation - Prevent interactive prompts for variables without a specified value:
export TF_INPUT=0

# Optional - Prevent Terraform CLI commands from outputting suggestions that are not helpful to automation:
export TF_IN_AUTOMATION=true

# Determine the S3 object key to which we will write/update Terraform state: 
export TERRAFORM_STATE_OBJECT_KEY="release/$RELEASE_APP_NAME/$RELEASE_BRANCH_NAME/$RELEASE_ENV_ID/tfstate"

# Set up our backend state file in S3: 
TERRAFORM_STATE_BUCKET_NAME="$TERRAFORM_STATE_BUCKET_NAME_PREFIX-$ACCOUNT_ID"

echo "Terraform state file will be kept at the following S3 bucket:"
echo "s3://$TERRAFORM_STATE_BUCKET_NAME/$TERRAFORM_STATE_OBJECT_KEY ($TERRAFORM_STATE_BUCKET_REGION)"

# Notice that a backend table (i.e. DynamoDB) is *not* present, which means statefiles cannot be locked.
# In production or other permanent environments, being able to lock state would typically be a good thing.
# However, with an ephemeral, stateless environment, we don't want to lock files because, if a job fails
# due to an error in the template, re-running the deployment after you find and fix the template error
# will still fail until you find and remove the proper item that represents the lock. When using ephemeral
# environments that are inherently more commonly used for experimentation, such template errors are
# also more common. By foregoing a lock table, we avoid adding unnecessary operational overhead:
terraform init -migrate-state -force-copy \
    -backend-config="key=$TERRAFORM_STATE_OBJECT_KEY" \
    -backend-config="bucket=$TERRAFORM_STATE_BUCKET_NAME" \
    -backend-config="region=$TERRAFORM_STATE_BUCKET_REGION"

echo [TERRAFORM INIT COMPLETE]
