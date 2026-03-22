output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID currently used by Terraform"
}

output "aws_region" {
  value       = data.aws_region.current.region
  description = "AWS region currently used by Terraform"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}

output "cluster_name" {
  value       = aws_eks_cluster.main.id
  description = "Name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint of the EKS cluster"
}