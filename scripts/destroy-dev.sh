# stop on any error (if any command fails, the script stops)
# fail on undefined variables (helpful to catch typos and misconfigurations)
# fail if any part of a pipeline fails (example: terraform output | grep something)
#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TF_DIR="$REPO_ROOT/terraform/environments/$ENVIRONMENT"
APP_DIR="$REPO_ROOT/apps/sample-app"

if [[ ! -d "$TF_DIR" ]]; then
  echo "Error: Terraform environment directory not found: $TF_DIR"
  exit 1
fi

if [[ ! -d "$APP_DIR" ]]; then
  echo "Error: App directory not found: $APP_DIR"
  exit 1
fi

cd "$TF_DIR"

kubectl delete -f "$APP_DIR/service.yaml"
kubectl delete -f "$APP_DIR/deployment.yaml"
kubectl delete -f "$APP_DIR/namespace.yaml"

terraform destroy -auto-approve