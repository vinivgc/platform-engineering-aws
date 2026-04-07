variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs of the public subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs of the private subnets"
}

variable "cluster_admin_principal_arn" {
  type        = string
  description = "IAM role or user ARN that should administer the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.33"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group"
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  type        = string
  description = "Capacity type for the managed node group"
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 2
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "node_disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes"
  default     = 20
}