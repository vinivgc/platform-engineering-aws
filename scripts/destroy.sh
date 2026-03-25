#!/usr/bin/env bash
set -euo pipefail

# Run the contents of common.sh inside this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

validate_environment "${1:-dev}"

# kubectl delete -f "$APP_DIR/service.yaml"
# kubectl delete -f "$APP_DIR/deployment.yaml"
# kubectl delete -f "$APP_DIR/namespace.yaml"

cd "$TF_PLA_ACC_DIR"

terraform init
terraform destroy -auto-approve

cd "$TF_ENV_DIR"

terraform init
terraform destroy -auto-approve