output "aws_load_balancer_controller_iam_role_arn" {
  value       = module.aws_load_balancer_controller.iam_role_arn
  description = "ARN of the IAM role used by the AWS Load Balancer Controller"
}

output "aws_load_balancer_controller_service_account_name" {
  value       = module.aws_load_balancer_controller.service_account_name
  description = "Name of the Kubernetes service account used by the AWS Load Balancer Controller"
}

output "aws_load_balancer_controller_helm_release_name" {
  value       = module.aws_load_balancer_controller.helm_release_name
  description = "Name of the Helm release for the AWS Load Balancer Controller"
}

output "metrics_server_helm_release_name" {
  value       = module.metrics_server.helm_release_name
  description = "Name of the Helm release for Metrics Server"
}