output "github_actions_oidc_provider_arn" {
  value       = module.github_actions_provider.github_actions_oidc_provider_arn
  description = "ARN of the GitHub Actions OIDC provider"
}

output "github_actions_ecr_role_arn" {
  value       = module.github_ecr_access.iam_role_arn
  description = "ARN of the IAM role assumed by GitHub Actions when executing ECR tasks"
}

output "github_actions_eks_role_arn_dev" {
  value       = module.github_eks_access_dev.iam_role_arn
  description = "ARN of the IAM role assumed by GitHub Actions when executing EKS tasks in Dev"
}

output "github_actions_eks_role_arn_prod" {
  value       = module.github_eks_access_prod.iam_role_arn
  description = "ARN of the IAM role assumed by GitHub Actions when executing EKS tasks in Prod"
}