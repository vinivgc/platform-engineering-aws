#!/usr/bin/env bash
set -euo pipefail

# Run the contents of common.sh inside this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

validate_environment "${1:-dev}"

cd "$TF_DIR"

kubectl delete -f "$APP_DIR/service.yaml"
kubectl delete -f "$APP_DIR/deployment.yaml"
kubectl delete -f "$APP_DIR/namespace.yaml"

terraform destroy -auto-approve