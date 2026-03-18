output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID currently used by Terraform"
}

output "aws_region" {
  value       = data.aws_region.current.region
  description = "AWS region currently used by Terraform"
}