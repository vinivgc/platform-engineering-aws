output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}