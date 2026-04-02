#!/usr/bin/env bash
set -euo pipefail

AWS_PROFILE="${AWS_PROFILE:-aws-administrator}"
AWS_REGION="${AWS_REGION:-eu-west-1}"
PROJECT_NAME="${PROJECT_NAME:-platform-engineering-aws}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLATFORM_DIR="${ROOT_DIR}/terraform/platform"
GH_ACCESS_DIR="${ROOT_DIR}/terraform/platform-access/github-actions"
PLATFORM_ADDONS_DIR="${ROOT_DIR}/terraform/platform-addons"

PLATFORM_AUTO_TFVARS="${PLATFORM_DIR}/terraform.auto.tfvars.json"
GH_ACCESS_AUTO_TFVARS="${GH_ACCESS_DIR}/terraform.auto.tfvars.json"
PLATFORM_ADDONS_AUTO_TFVARS="${PLATFORM_ADDONS_DIR}/terraform.auto.tfvars.json"

cleanup() {
  rm -f "$PLATFORM_AUTO_TFVARS" "$GH_ACCESS_AUTO_TFVARS" "$PLATFORM_ADDONS_AUTO_TFVARS"
}
trap cleanup EXIT

export AWS_PROFILE

echo "==> Reading platform outputs"
cd "$PLATFORM_DIR"
EKS_CLUSTER_NAME="$(terraform output -raw eks_cluster_name)"
EKS_CLUSTER_OIDC_PROVIDER_ARN="$(terraform output -raw eks_cluster_oidc_provider_arn)"
EKS_CLUSTER_OIDC_PROVIDER_URL="$(terraform output -raw eks_cluster_oidc_issuer_url)"
VPC_ID="$(terraform output -raw vpc_id)"
ECR_REPOSITORY_ARN="$(terraform output -raw ecr_repository_arn)"

echo "==> Formatting current user's ARN"
RAW_ARN="$(aws sts get-caller-identity --query Arn --output text)"

if [[ "$RAW_ARN" == *":assumed-role/"* ]]; then
  ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
  ROLE_NAME="$(echo "$RAW_ARN" | cut -d'/' -f2)"
  CLUSTER_ADMIN_PRINCIPAL_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
else
  CLUSTER_ADMIN_PRINCIPAL_ARN="$RAW_ARN"
fi

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

echo "==> Writing generated tfvars for platform-addons access stack"
cat > "$PLATFORM_ADDONS_AUTO_TFVARS" <<EOF
{
  "aws_region": "${AWS_REGION}",
  "project_name": "${PROJECT_NAME}",
  "eks_cluster_name": "${EKS_CLUSTER_NAME}",
  "eks_cluster_oidc_provider_arn": "${EKS_CLUSTER_OIDC_PROVIDER_ARN}",
  "eks_cluster_oidc_issuer_url": "${EKS_CLUSTER_OIDC_PROVIDER_URL}",
  "eks_cluster_vpc_id": "${VPC_ID}"
}
EOF

echo "==> Destroying platform-addons stack"
cd "$PLATFORM_ADDONS_DIR"
terraform init
terraform destroy -auto-approve

echo "==> Writing generated tfvars for platform-addons access stack"
cat > "$PLATFORM_ADDONS_AUTO_TFVARS" <<EOF
{
  "aws_region": "${AWS_REGION}",
  "project_name": "${PROJECT_NAME}",
  "eks_cluster_name": "${EKS_CLUSTER_NAME}",
  "eks_cluster_oidc_provider_arn": "${EKS_CLUSTER_OIDC_PROVIDER_ARN}",
  "eks_cluster_oidc_issuer_url": "${EKS_CLUSTER_OIDC_PROVIDER_URL}",
  "eks_cluster_vpc_id": "${VPC_ID}"
}
EOF

echo "==> Destroying platform-addons stack"
cd "$PLATFORM_ADDONS_DIR"
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