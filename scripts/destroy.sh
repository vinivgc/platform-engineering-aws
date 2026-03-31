#!/usr/bin/env bash
set -euo pipefail

AWS_PROFILE="${AWS_PROFILE:-your-profile}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLATFORM_DIR="${ROOT_DIR}/terraform/platform"
GH_ACCESS_DIR="${ROOT_DIR}/terraform/platform-access/github-actions"

export AWS_PROFILE

echo "==> Destroying github-actions access stack"
cd "$GH_ACCESS_DIR"
terraform init
terraform destroy -auto-approve

echo "==> Destroying platform stack"
cd "$PLATFORM_DIR"
terraform init
terraform destroy -auto-approve

echo "==> Done"