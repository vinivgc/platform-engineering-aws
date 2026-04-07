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
  default     = "3.2.1"
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Metrics Server Helm chart version"
  default     = "3.13.0"
}

variable "metrics_server_replicas" {
  type        = number
  description = "Number of Metrics Server replicas"
  default     = 2
}

variable "metrics_server_args" {
  type        = list(string)
  description = "Extra args for Metrics Server"
  default = [
    "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"
  ]
}