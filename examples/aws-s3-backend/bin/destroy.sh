#!/bin/bash
set -e

DIR=$(dirname -- "$0")
source $DIR/init.sh

echo "Running terraform plan..."
terraform plan

echo "Running terraform destroy..."
terraform destroy -auto-approve
