variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the target ECR repository"
}

variable "ecr_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions to ECR"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the target EKS cluster"
}

variable "eks_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions to EKS"
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