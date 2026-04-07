output "github_actions_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "ARN of the GitHub Actions OIDC provider"
}