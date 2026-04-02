variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
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

variable "eks_cluster_vpc_id" {
  type        = string
  description = "ID of the VPC where the EKS cluster is deployed"
}

variable "aws_load_balancer_controller_chart_version" {
  type        = string
  description = "AWS Load Balancer Controller Helm chart version"
  default     = "3.1.0"
}

variable "aws_load_balancer_controller_version" {
  type        = string
  description = "AWS Load Balancer Controller version for IAM policy"
  default     = "v3.1.0"
}

variable "aws_load_balancer_controller_role_name" {
  type = string
  description = "IAM role name for AWS Load Balancer Controller"
}