output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID currently used by Terraform"
}

output "aws_region" {
  value       = data.aws_region.current.region
  description = "AWS region currently used by Terraform"
}

output "vpc_id" {
  value       = module.networking.vpc_id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.networking.public_subnet_ids
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.networking.private_subnet_ids
  description = "IDs of the private subnets"
}

output "eks_cluster_name" {
  value       = module.eks_cluster.cluster_name
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = module.eks_cluster.cluster_endpoint
  description = "Endpoint of the EKS cluster"
}

output "eks_cluster_oidc_provider_arn" {
  value       = module.eks_cluster.cluster_oidc_provider_arn
  description = "ARN of the IAM OIDC provider associated with the EKS cluster"
}

output "eks_cluster_oidc_issuer_url" {
  value       = module.eks_cluster.cluster_oidc_issuer_url
  description = "OIDC issuer URL of the EKS cluster"
}

output "ecr_repository_arn" {
  value       = module.ecr.repository_arn
  description = "ARN of the ECR repository"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "URL of the main ECR repository"
}

output "ecr_repository_name" {
  value       = module.ecr.repository_name
  description = "Name of the main ECR repository"
}