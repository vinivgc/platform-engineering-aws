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
}

variable "controller_version" {
  type        = string
  description = "Controller version for IAM policy"
}

variable "namespace" {
  type        = string
  description = "Namespace where the controller will run"
  default     = "kube-system"
}

variable "service_account_name" {
  type        = string
  description = "Service account name used by the controller"
  default     = "aws-load-balancer-controller"
}

variable "enable_service_mutator_webhook" {
  type        = bool
  description = "Whether the controller should become the default controller for new LoadBalancer services"
  default     = true
}