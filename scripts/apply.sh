#!/usr/bin/env bash
set -euo pipefail

# Run the contents of common.sh inside this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

validate_environment "${1:-dev}"

cd "$TF_ENV_DIR"

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

# kubectl apply -f "$APP_DIR/namespace.yaml"
# kubectl apply -f "$APP_DIR/deployment.yaml"
# kubectl apply -f "$APP_DIR/service.yaml"