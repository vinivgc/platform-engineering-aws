output "iam_role_arn" {
  value       = aws_iam_role.aws_load_balancer_controller.arn
  description = "ARN of the IAM role used by the AWS Load Balancer Controller"
}

output "service_account_name" {
  value       = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  description = "Name of the Kubernetes service account used by the AWS Load Balancer Controller"
}

output "helm_release_name" {
  value       = helm_release.aws_load_balancer_controller.name
  description = "Name of the Helm release for the AWS Load Balancer Controller"
}