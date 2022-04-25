#!/bin/bash
set -e

# Purpose: Deploy a CloudFormation stack hich Creates an IAM role containing
# the pemissions needed by Terraform to create your demo infrastructure.

STACK_NAME="release-with-terraform-demo"
TEMPLATE_PATH="examples/prerequisites/cloudformation.yaml"

aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE_PATH \
    --capabilities CAPABILITY_NAMED_IAM