variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the target ECR repository"
}

variable "github_actions_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub Actions OIDC provider"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch allowed to assume the role"
}

variable "github_org" {
  type        = string
  description = "GitHub owner or organization"
}

variable "github_repo" {
  type        = string
  description = "Name of the GitHub repository"
}