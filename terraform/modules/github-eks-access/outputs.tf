output "iam_role_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN of the IAM role assumed by GitHub Actions"
}