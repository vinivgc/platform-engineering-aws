output "repository_arn" {
  value       = aws_ecr_repository.main.arn
  description = "ARN of ECR repository"
}

output "repository_name" {
  value       = aws_ecr_repository.main.name
  description = "Name of ECR repository"
}

output "repository_url" {
  value       = aws_ecr_repository.main.repository_url
  description = "URL of ECR repository"
}