output "iam_role_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN of the IAM role used by the AWS Load Balancer Controller"
}

output "service_account_name" {

  value       = kubernetes_service_account_v1.this.metadata[0].name
  description = "Name of the Kubernetes service account used by the AWS Load Balancer Controller"
}

output "helm_release_name" {
  value       = helm_release.this.name
  description = "Name of the Helm release for the AWS Load Balancer Controller"
}