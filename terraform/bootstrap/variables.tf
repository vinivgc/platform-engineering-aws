variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for resources"
}