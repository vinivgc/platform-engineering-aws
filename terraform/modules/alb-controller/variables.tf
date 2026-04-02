variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_cluster_oidc_provider_arn" {
  type        = string
  description = "ARN of the IAM OIDC provider associated with the EKS cluster"
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL of the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EKS cluster is deployed"
}

variable "role_name" {
  type        = string
  description = "IAM role name for AWS Load Balancer Controller"
}

variable "chart_version" {
  type        = string
  description = "AWS Load Balancer Controller Helm chart version"
  default     = "1.7.1"
}

variable "controller_version" {
  type        = string
  description = "Controller version for IAM policy"
  default     = "v2.7.1"
}