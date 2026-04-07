variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the target ECR repository"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the target EKS cluster"
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