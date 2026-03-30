#!/usr/bin/env bash
set -euo pipefail

# Run the contents of common.sh inside this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

validate_structure

setup_profile

cd "$TF_PLA_DIR"

terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

cd "$TF_PLA_ACC_DIR"

terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

setup_config

kubectl get nodes