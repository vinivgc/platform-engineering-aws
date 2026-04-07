variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "eks_cluster_name" {
  type        = string
  default     = null
  description = "(Optional) Name of the EKS cluster to join the network"
}