variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}

variable "ecr_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
}

variable "eks_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
}

variable "github_org" {
  type        = string
  description = "GitHub owner or organization"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch allowed to assume the role"
}