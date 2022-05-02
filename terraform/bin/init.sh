#!/bin/bash
set -o pipefail -e

DIR=$(dirname -- "$0")

function main() {
    FILE="init_complete"
    if test -f "$FILE"; then
       echo "[TERRAFORM ALREADY INITIALIZED]"
      exit 0
    else
        initializeTerraform       
    fi
}

function initializeTerraform() {
    echo "[BEGIN TERRAFORM INIT]"
    assumeAwsIamRole "$TERRAFORM_DEPLOYMENT_ROLE_NAME"
    configureTerraformCli
    terraform init -migrate-state -force-copy \
        -backend-config="key=$TERRAFORM_STATE_OBJECT_KEY" \
        -backend-config="bucket=$TERRAFORM_STATE_BUCKET_NAME" \
        -backend-config="region=$TERRAFORM_STATE_BUCKET_REGION"
    echo "[END TERRAFORM INIT]"
}

function assumeAwsIamRole() {
    local roleName="$1"
    exportAwsAccountId
    exportAwsAssumedRoleCredentials
    export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS | jq -r '.Credentials.AccessKeyId') 
    export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo $AWS_CREDENTIALS | jq -r '.Credentials.SessionToken')
}

function exportAwsAccountId() {
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
    if [[ $? != 0 ]]; then
        exit 1
    fi
}

function exportAwsAssumedRoleCredentials() {
    export DEPLOYMENT_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${roleName}"
    AWS_CREDENTIALS=$(aws sts assume-role --role-arn "$DEPLOYMENT_ROLE_ARN" --role-session-name "release-$RELEASE_APP_NAME-$RELEASE_ENV_ID-terraform" --output json)
    if [[ $? != 0 ]]; then
        echo "Failed to get AWS credentials for assumed role."
        exit 1
    else
        export AWS_CREDENTIALS=$AWS_CREDENTIALS
    fi
}

function configureTerraformCli() {
    # Disable interactive prompts and compress log
    # output to a format friendly for automation:
    export TF_INPUT=0
    export TF_IN_AUTOMATION=true

    # Determine location to store Terraform state file:
    export TERRAFORM_STATE_BUCKET_NAME="$TERRAFORM_STATE_BUCKET_NAME_PREFIX-$AWS_ACCOUNT_ID"
    export TERRAFORM_STATE_OBJECT_KEY="release/$RELEASE_APP_NAME/$RELEASE_BRANCH_NAME/$RELEASE_ENV_ID/tfstate"
    echo "Terraform state location: s3://$TERRAFORM_STATE_BUCKET_NAME/$TERRAFORM_STATE_OBJECT_KEY ($TERRAFORM_STATE_BUCKET_REGION)"
}

main || exit 1