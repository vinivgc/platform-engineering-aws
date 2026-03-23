variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "aws_profile" {
  type        = string
  description = "Profile used to execute operations"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for resources"
}

variable "github_org" {
  description = "GitHub owner or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the role"
  type        = string
}

variable "role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
}

variable "eks_cluster_name" {
  description = "Target EKS cluster name"
  type        = string
}