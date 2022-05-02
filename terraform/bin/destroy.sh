#!/bin/bash
set -o pipefail -e

DIR=$(dirname -- "$0")
source $DIR/init.sh || exit 1
source $DIR/plan.sh || exit 1

echo "[BEGIN TERRAFORM DESTROY]"
terraform destroy -auto-approve
echo "[END TERRAFORM DESTROY]"
