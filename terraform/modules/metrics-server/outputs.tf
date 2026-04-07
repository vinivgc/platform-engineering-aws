output "helm_release_name" {
  value       = helm_release.metrics_server.name
  description = "Name of the Helm release for Metrics Server"
}