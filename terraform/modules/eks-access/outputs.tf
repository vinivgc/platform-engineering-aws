output "role_cluster_arn" {
  value       = aws_iam_role.eks_cluster.arn
  description = "EKS cluster arn"
}

output "role_nodes_arn" {
  value       = aws_iam_role.eks_nodes.arn
  description = "EKS node group arn"
}