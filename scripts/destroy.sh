#!/usr/bin/env bash
set -euo pipefail

AWS_PROFILE="${AWS_PROFILE:-aws-administrator}"
AWS_REGION="${AWS_REGION:-eu-west-1}"
PROJECT_NAME="${PROJECT_NAME:-platform-engineering-aws}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLATFORM_DIR="${ROOT_DIR}/terraform/platform"
GH_ACCESS_DIR="${ROOT_DIR}/terraform/platform-access/github-actions"

PLATFORM_AUTO_TFVARS="${PLATFORM_DIR}/terraform.auto.tfvars.json"
GH_ACCESS_AUTO_TFVARS="${GH_ACCESS_DIR}/terraform.auto.tfvars.json"

cleanup() {
  rm -f "$PLATFORM_AUTO_TFVARS" "$GH_ACCESS_AUTO_TFVARS"
}
trap cleanup EXIT

export AWS_PROFILE

echo "==> Reading platform outputs"
EKS_CLUSTER_NAME="$(terraform output -raw eks_cluster_name)"
ECR_REPOSITORY_ARN="$(terraform output -raw ecr_repository_arn)"

echo "==> Writing generated tfvars for github-actions access stack"
cat > "$GH_ACCESS_AUTO_TFVARS" <<EOF
{
  "aws_region": "${AWS_REGION}",
  "project_name": "${PROJECT_NAME}",
  "eks_cluster_name": "${EKS_CLUSTER_NAME}",
  "ecr_repository_arn": "${ECR_REPOSITORY_ARN}"
}
EOF

echo "==> Destroying github-actions access stack"
cd "$GH_ACCESS_DIR"
terraform init
terraform destroy -auto-approve

echo "==> Writing generated tfvars for platform stack"
cat > "$PLATFORM_AUTO_TFVARS" <<EOF
{
  "aws_region": "${AWS_REGION}",
  "project_name": "${PROJECT_NAME}"
}
EOF

echo "==> Destroying platform stack"
cd "$PLATFORM_DIR"
terraform init
terraform destroy -auto-approve

echo "==> Done"