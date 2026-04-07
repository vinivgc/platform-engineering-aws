output "helm_release_name" {
  value       = helm_release.this.name
  description = "Name of the Helm release for Metrics Server"
}