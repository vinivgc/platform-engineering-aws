variable "project_name" {
  type        = string
  description = "Name of the Project"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment"
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