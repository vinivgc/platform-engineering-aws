variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "scan_on_push" {
  type        = bool
  description = "Whether to enable image scanning on push"
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "Image tag mutability setting for the ECR repository"
  default     = "MUTABLE"
}

variable "lifecycle_policy_enabled" {
  type        = bool
  description = "Whether to apply an ECR lifecycle policy"
  default     = true
}

variable "untagged_image_retention_count" {
  type        = number
  description = "Number of untagged images to retain before expiring older ones"
  default     = 10
}