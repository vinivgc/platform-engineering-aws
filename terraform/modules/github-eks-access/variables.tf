variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "github_actions_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub Actions OIDC provider"
}

variable "github_environment" {
  type        = string
  description = "GitHub environment allowed to assume this role"
}

variable "github_org" {
  type        = string
  description = "GitHub owner or organization"
}

variable "github_repo" {
  type        = string
  description = "Name of the GitHub repository"
}