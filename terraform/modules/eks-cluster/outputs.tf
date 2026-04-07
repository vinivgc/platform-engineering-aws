output "cluster_id" {
  value       = aws_eks_cluster.main.id
  description = "ID of the EKS cluster"
}

output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "Name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint of the EKS cluster"
}

output "cluster_iam_role_arn" {
  value       = aws_iam_role.eks_cluster.arn
  description = "ARN of the IAM role used by the EKS control plane"
}

output "node_iam_role_arn" {
  value       = aws_iam_role.eks_nodes.arn
  description = "ARN of the IAM role used by the EKS managed node group"
}

output "cluster_oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  value       = local.cluster_oidc_issuer_url
}