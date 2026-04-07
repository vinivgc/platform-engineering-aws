output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "ARN of ECR repository"
}

output "repository_name" {
  value       = aws_ecr_repository.this.name
  description = "Name of ECR repository"
}

output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "URL of ECR repository"
}