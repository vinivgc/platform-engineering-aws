variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs of the public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of the private subnets"
}

variable "role_eks_cluster_arn" {
  type        = string
  description = "ARN of the EKS cluster"
}

variable "role_eks_nodes_arn" {
  type        = string
  description = "ARN of the EKS node group"
}