# stop on any error (if any command fails, the script stops)
# fail on undefined variables (helpful to catch typos and misconfigurations)
# fail if any part of a pipeline fails (example: terraform output | grep something)
#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT/terraform/environments/$ENVIRONMENT"

terraform fmt
terraform validate
terraform apply -auto-approve

aws eks update-kubeconfig \
  --region eu-west-1 \
  --name "platform-engineering-aws-${ENVIRONMENT}-eks"

kubectl get nodes