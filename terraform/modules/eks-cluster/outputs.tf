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