#!/bin/bash
set -e
# the pemissions needed by Terraform to create your demo infrastructure.

STACK_NAME="release-with-terraform-demo"

aws cloudformation delete-stack --stack-name $STACK_NAME

