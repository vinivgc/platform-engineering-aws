variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for resources"
}

variable "aws_profile" {
  type        = string
  description = "Profile used to execute operations"
}