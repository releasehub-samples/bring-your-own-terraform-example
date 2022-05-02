#!/bin/bash
set -o pipefail -e

DIR=$(dirname -- "$0")
source $DIR/init.sh || exit 1

echo "[BEGIN TERRAFORM PLAN]"
terraform plan
echo "[END TERRAFORM PLAN]"